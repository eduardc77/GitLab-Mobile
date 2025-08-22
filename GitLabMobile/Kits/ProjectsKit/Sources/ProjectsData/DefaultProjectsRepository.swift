//
//  DefaultProjectsRepository.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabUtilities
import ProjectsCache
import GitLabNetwork

public actor DefaultProjectsRepository: ProjectsRepository {
	private let remote: ProjectsRemoteDataSource
	private let local: ProjectsLocalDataSource
	private let now: () -> Date
	private let staleness: TimeInterval
	private let perPageDefault: Int

	public init(
		remote: ProjectsRemoteDataSource,
		local: ProjectsLocalDataSource,
		now: @escaping () -> Date = Date.init,
		staleness: TimeInterval = StoreDefaults.cacheStaleInterval,
		perPageDefault: Int = StoreDefaults.perPage
	) {
		self.remote = remote
		self.local = local
		self.now = now
		self.staleness = staleness
		self.perPageDefault = perPageDefault
	}

	public func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async {
		await local.configure(makeCache: makeCache)
	}

	public func explorePage(
		orderBy: ProjectSortField,
		sort: SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error> {
		let cacheKey = makeExploreCacheKey(orderBy: orderBy, sort: sort, search: search)
		let local = self.local
		let remote = self.remote
		let staleness = self.staleness
		return AsyncThrowingStream { continuation in
			Task {
				let cached = await local.readPage(cacheKey: cacheKey, page: page, limit: perPage, staleInterval: staleness)
				if let value = cached.value, value.isEmpty == false {
					continuation.yield(
						RepositoryResult(
							value: RepositoryPage(items: value, nextPage: cached.nextPage),
							isStale: !cached.isFresh
						)
					)
					// If cache is fresh, skip network revalidation except for page 1 (SWR for first page)
					if cached.isFresh && page != 1 {
						continuation.finish()
						return
					}
				}
				do {
					let pagedDTOs = try await remote.fetchExplore(
						orderBy: orderBy.endpointSortBy,
						sort: sort.endpointSortDirection,
						page: page,
						perPage: perPage,
						search: search
					)
					let models = pagedDTOs.items.map { $0.toDomain() }
					await local.writePage(
						cacheKey: cacheKey,
						page: page,
						items: models,
						nextPage: pagedDTOs.pageInfo?.nextPage
					)
					continuation.yield(
						RepositoryResult(
							value: RepositoryPage(items: models, nextPage: pagedDTOs.pageInfo?.nextPage),
							isStale: false
						)
					)
					continuation.finish()
				} catch {
					if cached.value != nil {
						continuation.finish()
					} else {
						continuation.finish(throwing: error)
					}
				}
			}
		}
	}

	public func personalPage(
		scope: PersonalProjectsScope,
		page: Int,
		perPage: Int,
		search: String?
	) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error> {
		let cacheKey = makePersonalCacheKey(scope: scope, search: search)
		let local = self.local
		let remote = self.remote
		let staleness = self.staleness
		return AsyncThrowingStream { continuation in
			Task {
				let cached = await local.readPage(cacheKey: cacheKey, page: page, limit: perPage, staleInterval: staleness)
				if let value = cached.value, value.isEmpty == false {
					continuation.yield(
						RepositoryResult(
							value: RepositoryPage(items: value, nextPage: cached.nextPage),
							isStale: !cached.isFresh
						)
					)
					// If cache is fresh, skip network revalidation except for page 1 (SWR for first page)
					if cached.isFresh && page != 1 {
						continuation.finish()
						return
					}
				}
				do {
					let result = try await computePersonalRemote(
						scope: scope,
						page: page,
						perPage: perPage,
						search: search,
						remote: remote
					)
					await local.writePage(
						cacheKey: cacheKey,
						page: page,
						items: result.items,
						nextPage: result.pageInfo?.nextPage
					)
					continuation.yield(
						RepositoryResult(
							value: RepositoryPage(items: result.items, nextPage: result.pageInfo?.nextPage),
							isStale: false
						)
					)
					continuation.finish()
				} catch {
					if cached.value != nil {
						continuation.finish()
					} else {
						continuation.finish(throwing: error)
					}
				}
			}
		}
	}

	private func computePersonalRemote(
		scope: PersonalProjectsScope,
		page: Int,
		perPage: Int,
		search: String?,
		remote: ProjectsRemoteDataSource
	) async throws -> Paginated<[ProjectSummary]> {
		switch scope {
		case .owned:
			return try await remote.fetchPersonalOwned(
				page: page,
				perPage: perPage,
				search: search
			)
		case .membership:
			return try await remote.fetchPersonalMembership(
				page: page,
				perPage: perPage,
				search: search
			)
		case .starred:
			return try await remote.fetchPersonalStarred(
				page: page,
				perPage: perPage,
				search: search
			)
		case .contributed:
			return try await remote.fetchPersonalContributed(
				page: page,
				perPage: perPage,
				search: search
			)
		case .combined:
			async let ownedTask = remote.fetchPersonalOwned(page: page, perPage: perPage, search: search)
			async let memberTask = remote.fetchPersonalMembership(page: page, perPage: perPage, search: search)
			let (owned, membership) = try await (ownedTask, memberTask)
			let merger = ListMerger()
			let merged = await merger.appendUniqueById(existing: owned.items, newItems: membership.items)
			let sorted = merged.sorted { ($0.lastActivityAt ?? .distantPast) > ($1.lastActivityAt ?? .distantPast) }
			let next = [owned.pageInfo?.nextPage, membership.pageInfo?.nextPage].compactMap { $0 }.min()
			let info = PageInfo(
				page: page,
				perPage: perPage,
				nextPage: next,
				prevPage: nil,
				total: nil,
				totalPages: nil
			)
			return Paginated(items: sorted, pageInfo: info)
		}
	}

	// MARK: - Keys
	private func makeExploreCacheKey(
		orderBy: ProjectSortField,
		sort: SortDirection,
		search: String?
	) -> String {
		let trimmed = search?.trimmingCharacters(in: .whitespacesAndNewlines)
		let lowered = trimmed?.lowercased()
		let queryPart = (lowered?.isEmpty == false) ? (lowered ?? "__none__") : "__none__"
		return "explore:\(orderBy.rawValue):\(sort.rawValue):\(queryPart)"
	}

	private func makePersonalCacheKey(scope: PersonalProjectsScope, search: String?) -> String {
		let scopePart: String
		switch scope {
		case .owned: scopePart = "owned"
		case .membership: scopePart = "membership"
		case .starred: scopePart = "starred"
		case .contributed: scopePart = "contributed"
		case .combined: scopePart = "combined"
		}
		let trimmed = search?.trimmingCharacters(in: .whitespacesAndNewlines)
		let lowered = trimmed?.lowercased()
		let queryPart = (lowered?.isEmpty == false) ? (lowered ?? "__none__") : "__none__"
		return "personal:\(scopePart):\(queryPart)"
	}

	public func projectDetails(id: Int) async throws -> ProjectDetails {
		let dto = try await remote.fetchProjectDetails(id: id)
		return ProjectDetails(
			id: dto.id,
			name: dto.name,
			pathWithNamespace: dto.pathWithNamespace,
			description: dto.description,
			starCount: dto.starCount ?? 0,
			forksCount: dto.forksCount ?? 0,
			avatarUrl: dto.avatarUrl.flatMap(URL.init),
			webUrl: URL(string: dto.webUrl) ?? URL(string: "https://gitlab.com") ?? URL(fileURLWithPath: "/"),
			lastActivityAt: dto.lastActivityAt
		)
	}
}
