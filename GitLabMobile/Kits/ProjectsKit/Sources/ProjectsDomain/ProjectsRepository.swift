//
//  ProjectsRepository.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

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
}
