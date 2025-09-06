//
//  DefaultProjectsRepository+Personal.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabUtilities
import ProjectsCache
import GitLabNetwork
import GitLabLogging

// MARK: - Personal Projects
extension DefaultProjectsRepository {

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

    // swiftlint:disable function_body_length
    private func computePersonalRemote(
        scope: PersonalProjectsScope,
        page: Int,
        perPage: Int,
        search: String?,
        remote: ProjectsRemoteDataSource
    ) async throws -> Paginated<[ProjectSummary]> {
        switch scope {
        case .owned:
            let dtoPage = try await remote.fetchPersonalOwned(
                page: page,
                perPage: perPage,
                search: search
            )
            return Paginated(items: dtoPage.items.map { $0.toDomain() }, pageInfo: dtoPage.pageInfo)
        case .membership:
            let dtoPage = try await remote.fetchPersonalMembership(
                page: page,
                perPage: perPage,
                search: search
            )
            return Paginated(items: dtoPage.items.map { $0.toDomain() }, pageInfo: dtoPage.pageInfo)
        case .starred:
            let dtoPage = try await remote.fetchPersonalStarred(
                page: page,
                perPage: perPage,
                search: search
            )
            return Paginated(items: dtoPage.items.map { $0.toDomain() }, pageInfo: dtoPage.pageInfo)
        case .contributed:
            let dtoPage = try await remote.fetchPersonalContributed(
                page: page,
                perPage: perPage,
                search: search
            )
            return Paginated(items: dtoPage.items.map { $0.toDomain() }, pageInfo: dtoPage.pageInfo)
        case .combined:
            async let ownedTask: Paginated<[ProjectDTO]> = remote.fetchPersonalOwned(page: page, perPage: perPage, search: search)
            async let memberTask: Paginated<[ProjectDTO]> = remote.fetchPersonalMembership(
                page: page,
                perPage: perPage,
                search: search
            )
            let (ownedDTOs, membershipDTOs) = try await (ownedTask, memberTask)
            let owned = ownedDTOs.items.map { $0.toDomain() }
            let membership = membershipDTOs.items.map { $0.toDomain() }
            let merger = ListMerger()
            let merged = await merger.appendUniqueById(existing: owned, newItems: membership)
            let sorted = merged.sorted { ($0.lastActivityAt ?? .distantPast) > ($1.lastActivityAt ?? .distantPast) }
            let next = [ownedDTOs.pageInfo?.nextPage, membershipDTOs.pageInfo?.nextPage].compactMap { $0 }.min()
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
    // swiftlint:enable function_body_length

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
}
