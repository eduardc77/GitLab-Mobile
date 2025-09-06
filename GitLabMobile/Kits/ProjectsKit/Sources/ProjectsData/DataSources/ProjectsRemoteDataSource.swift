//
//  ProjectsRemoteDataSource.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork
import GitLabLogging
import ProjectsDomain

// MARK: - Private Errors

private enum CommitsCountError: Error {
	case branchNotFound
	case noCommitsFound
	case allStrategiesFailed
}

extension ProjectDTO {
    func toDomain() -> ProjectSummary {
        ProjectSummary(
            id: id,
            name: name,
            pathWithNamespace: pathWithNamespace,
            namespaceName: namespace?.name,
            description: description,
            starCount: starCount ?? 0,
            forksCount: forksCount ?? 0,
            avatarUrl: avatarUrl.flatMap(URL.init),
            webUrl: URL(string: webUrl) ?? URL(string: "https://gitlab.com/project/\(id)") ?? URL(fileURLWithPath: "/"),
            lastActivityAt: lastActivityAt
        )
    }
}

public protocol ProjectsRemoteDataSource: Sendable {
	func fetchExplore(
		orderBy: ProjectsEndpoints.SortBy,
		sort: ProjectsEndpoints.SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async throws -> Paginated<[ProjectDTO]>

	func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]>
	func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]>
	func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]>
	func fetchPersonalContributed(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]>

	func fetchProjectDetails(id: Int) async throws -> ProjectDTO

	// Extra details
	func fetchIssuesOpenCount(projectId: Int) async throws -> Int
	func fetchMergeRequestsOpenCount(projectId: Int, state: String) async throws -> Paginated<[MRCountProbeDTO]>
	func fetchContributorsCount(projectId: Int, ref: String?) async throws -> Int
	func fetchReleasesCount(projectId: Int) async throws -> Int
	func fetchMilestonesCount(projectId: Int) async throws -> Int
	func fetchRepositoryStatistics(projectId: Int) async throws -> RepositoryStatisticsDTO
	func fetchCommitSequence(projectId: Int, sha: String) async throws -> CommitSequenceDTO
	func fetchCommitsCount(projectId: Int, ref: String?) async throws -> Int
	func fetchBranches(projectId: Int) async throws -> [BranchDTO]
	func fetchLicense(projectId: Int) async throws -> Data
	func fetchLicenseType(projectId: Int) async -> String?

	func fetchRepositoryTree(projectId: Int, path: String?, ref: String?) async throws -> [RepositoryTreeItemDTO]
	func fetchRawFile(projectId: Int, path: String, ref: String?) async throws -> Data
	func fetchRawBlob(projectId: Int, sha: String) async throws -> Data
	func fetchDefaultBranch(projectId: Int) async throws -> String?

	// README functionality
	func fetchREADMEContent(projectId: Int, path: String, ref: String?) async throws -> Data
}

public struct DefaultProjectsRemoteDataSource: ProjectsRemoteDataSource {

	private let api: APIClientProtocol

	public init(api: APIClientProtocol) { self.api = api }

	public func fetchExplore(
		orderBy: ProjectsEndpoints.SortBy,
		sort: ProjectsEndpoints.SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async throws -> Paginated<[ProjectDTO]> {
		try await api.sendPaginated(
			ProjectsEndpoints.list(
				orderBy: orderBy,
				sort: sort,
				page: page,
				perPage: perPage,
				search: search,
				publicOnly: true
			)
		)
	}

	public func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]> {
        let endpoint = ProjectsEndpoints.owned(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return dto
	}

    public func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]> {
        let endpoint = ProjectsEndpoints.membership(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return dto
    }

    public func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]> {
        let endpoint = ProjectsEndpoints.starred(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return dto
    }

    public func fetchPersonalContributed(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectDTO]> {
        let endpoint = ProjectsEndpoints.contributed(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return dto
    }

	public func fetchProjectDetails(id: Int) async throws -> ProjectDTO {
		try await api.send(ProjectsEndpoints.project(id: id))
	}

	public func fetchIssuesOpenCount(projectId: Int) async throws -> Int {
		let endpoint = ProjectsEndpoints.issuesStatistics(projectId: projectId)
		let dto = try await api.send(endpoint)
		return dto.statistics.counts.opened ?? 0
	}

	public func fetchRepositoryStatistics(projectId: Int) async throws -> RepositoryStatisticsDTO {
		let endpoint = ProjectsEndpoints.repositoryStatistics(projectId: projectId)
		return try await api.send(endpoint)
	}

	public func fetchCommitSequence(projectId: Int, sha: String) async throws -> CommitSequenceDTO {
		let endpoint = ProjectsEndpoints.commitSequence(projectId: projectId, sha: sha)
		return try await api.send(endpoint)
	}

	public func fetchMergeRequestsOpenCount(projectId: Int, state: String) async throws -> Paginated<[MRCountProbeDTO]> {
		let endpoint = ProjectsEndpoints.mergeRequestsCount(projectId: projectId, state: state)
		let paginated: Paginated<[MRCountProbeDTO]> = try await api.sendPaginated(endpoint)
		return paginated
	}

	public func fetchContributorsCount(projectId: Int, ref: String?) async throws -> Int {
		// For total contributors across ALL branches, omit the ref parameter
		// When ref is provided, GitLab filters to only that branch's contributors
		let endpoint = ProjectsEndpoints.contributors(projectId: projectId, perPage: 1, ref: nil)
		let paginated: Paginated<[ContributorsDTO]> = try await api.sendPaginated(endpoint)
		return paginated.pageInfo?.total ?? 0
	}

	public func fetchReleasesCount(projectId: Int) async throws -> Int {
		// Use pagination to get total count efficiently
		let endpoint = ProjectsEndpoints.releases(projectId: projectId, page: 1, perPage: 1)
		let paginated: Paginated<[ReleaseDTO]> = try await api.sendPaginated(endpoint)
		return paginated.pageInfo?.total ?? 0

	}

	public func fetchBranches(projectId: Int) async throws -> [BranchDTO] {
		let endpoint = ProjectsEndpoints.branches(projectId: projectId)
		return try await api.send(endpoint)
	}

	public func fetchMilestonesCount(projectId: Int) async throws -> Int {
		// Milestones endpoint doesn't support X-Total headers, so we fetch and count directly
		let endpoint = ProjectsEndpoints.milestones(projectId: projectId, page: 1, perPage: 100)
		let milestones: [MilestoneDTO] = try await api.send(endpoint)
		return milestones.count
	}

	public func fetchCommitsCount(projectId: Int, ref: String?) async throws -> Int {
		let effectiveRef = ref ?? "master"
		AppLog.projects.debug("🔄 fetchCommitsCount called for project \(projectId), branch: \(effectiveRef)")

		// Try strategies in order of preference
		let strategies: [() async throws -> Int] = [
			{ try await self.branchesStrategy(projectId: projectId, ref: effectiveRef) },
			{ try await self.commitsStrategy(projectId: projectId, ref: effectiveRef) },
			{ try await self.repositoryStatsStrategy(projectId: projectId, ref: effectiveRef) },
		]

		for strategy in strategies {
			do {
				let count = try await strategy()
				AppLog.projects.debug("✅ Successfully got commit count: \(count) for \(effectiveRef)")
				return count
			} catch {
				AppLog.projects.debug("❌ Strategy failed: \(error.localizedDescription)")
				continue
			}
		}

		throw CommitsCountError.allStrategiesFailed
	}

	// MARK: - Private Strategies

	private func branchesStrategy(projectId: Int, ref: String) async throws -> Int {
		let branches = try await fetchBranches(projectId: projectId)
		guard let branch = branches.first(where: { $0.name == ref }),
			  let commitSHA = branch.commit?.id else {
			throw CommitsCountError.branchNotFound
		}

		let sequenceDTO = try await fetchCommitSequence(projectId: projectId, sha: commitSHA)
		return sequenceDTO.count
	}

	private func commitsStrategy(projectId: Int, ref: String) async throws -> Int {
		let commitsEndpoint = ProjectsEndpoints.commits(projectId: projectId, ref: ref, page: 1, perPage: 1)
		let commits: [CommitDTO] = try await api.send(commitsEndpoint)

		guard let latestCommit = commits.first, let sha = latestCommit.id else {
			throw CommitsCountError.noCommitsFound
		}

		let sequenceDTO = try await fetchCommitSequence(projectId: projectId, sha: sha)
		return sequenceDTO.count
	}

	private func repositoryStatsStrategy(projectId: Int, ref: String) async throws -> Int {
		let dto = try await fetchRepositoryStatistics(projectId: projectId)
		let count = dto.statistics.counts.commits ?? 0
		AppLog.projects.debug("⚠️ Using repository stats: \(count) (same for all branches)")
		return count
	}

	public func fetchLicense(projectId: Int) async throws -> Data {
		let endpoint = Endpoint<Data>(
			path: "/projects/\(projectId)/license",
			options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: false)
		)
		return try await api.send(endpoint)
	}

	public func fetchLicenseType(projectId: Int) async -> String? {
		// Try to get license data and extract type
		do {
			let licenseData = try await fetchLicense(projectId: projectId)
			if let licenseString = String(data: licenseData, encoding: .utf8) {
				// Extract license type from the license text (usually the first line)
				let lines = licenseString.split(separator: "\n", maxSplits: 1)
				if let firstLine = lines.first {
					return String(firstLine).trimmingCharacters(in: .whitespacesAndNewlines)
				}
			}
		} catch {
			// License not available or error parsing
		}
		return nil
	}

	public func fetchRepositoryTree(projectId: Int, path: String?, ref: String?) async throws -> [RepositoryTreeItemDTO] {
		try await api.send(ProjectsEndpoints.repositoryTree(projectId: projectId, path: path, ref: ref))
	}

	public func fetchRawFile(projectId: Int, path: String, ref: String?) async throws -> Data {
		try await api.send(ProjectsEndpoints.rawFile(projectId: projectId, path: path, ref: ref))
	}

	public func fetchRawBlob(projectId: Int, sha: String) async throws -> Data {
		try await api.send(ProjectsEndpoints.rawBlob(projectId: projectId, sha: sha))
	}

	public func fetchDefaultBranch(projectId: Int) async throws -> String? {
		// The project(id:) endpoint includes default_branch
		let dto: ProjectDTO = try await api.send(ProjectsEndpoints.project(id: projectId))
		return dto.defaultBranch
	}

	public func fetchREADMEContent(projectId: Int, path: String, ref: String?) async throws -> Data {
		try await api.send(ProjectsEndpoints.rawFile(projectId: projectId, path: path, ref: ref))
	}
}
