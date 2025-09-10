//
//  ProjectsRepository.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

// Import networking types needed for URL building
public typealias NetworkingConfig = GitLabNetwork.NetworkingConfig

public struct RepositoryResult<T: Sendable>: Sendable {
	public let value: T
	public let isStale: Bool
	public init(value: T, isStale: Bool) {
		self.value = value
		self.isStale = isStale
	}
}

public struct RepositoryPage<T: Sendable>: Sendable {
	public let items: T
	public let nextPage: Int?
	public init(items: T, nextPage: Int?) {
		self.items = items
		self.nextPage = nextPage
	}
}

public enum PersonalProjectsScope: Sendable, Equatable {
	case owned
	case membership
	case starred
	case contributed
	case combined
}

public protocol ProjectsRepository: Sendable {
	func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async

	// Explore (public)
	func explorePage(
		orderBy: ProjectSortField,
		sort: SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error>

	// Personal (authenticated)
	func personalPage(
		scope: PersonalProjectsScope,
		page: Int,
		perPage: Int,
		search: String?
	) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error>

	// Details (single project)
	func projectDetails(id: Int) async throws -> ProjectDetails
	func forceRefreshProjectDetails(id: Int) async throws -> ProjectDetails

	// Details extras
	func openIssuesCount(projectId: Int) async throws -> Int
	func openMergeRequestsCount(projectId: Int) async throws -> Int
	func contributorsCount(projectId: Int, ref: String?) async throws -> Int
	func releasesCount(projectId: Int) async throws -> Int
	func milestonesCount(projectId: Int) async throws -> Int
	func commitsCount(projectId: Int, ref: String?) async throws -> Int
	func branches(projectId: Int) async throws -> [Branch]
	func license(projectId: Int) async throws -> Data
	func licenseType(projectId: Int) async -> String?
	func repositoryTree(projectId: Int, path: String?, ref: String?) async throws -> [ProjectRepositoryItem]
	func rawFile(projectId: Int, path: String, ref: String?) async throws -> Data
	func rawFileURL(projectId: Int, path: String, ref: String?, networkingConfig: NetworkingConfig) async throws -> URL
	func rawBlob(projectId: Int, sha: String) async throws -> Data

	// README functionality
	func projectREADME(projectId: Int, ref: String?) async throws -> ProjectREADME

}

// MARK: - Convenience helpers (default protocol extension)
public extension ProjectsRepository {
    func forceRefreshProjectDetails(id: Int) async throws -> ProjectDetails {
        // Default implementation just calls regular projectDetails
        // Subclasses can override for more sophisticated cache clearing
        try await projectDetails(id: id)
    }
}
