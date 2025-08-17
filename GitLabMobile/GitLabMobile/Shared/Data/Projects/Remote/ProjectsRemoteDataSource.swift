//
//  ProjectsRemoteDataSource.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol ProjectsRemoteDataSource: Sendable {
	func fetchExplore(
		orderBy: ProjectsAPI.SortBy,
		sort: ProjectsAPI.SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async throws -> Paginated<[ProjectDTO]>

	func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
	func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
	func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
}

public struct DefaultProjectsRemoteDataSource: ProjectsRemoteDataSource {
	private let api: APIClient

	public init(api: APIClient) { self.api = api }

	public func fetchExplore(
		orderBy: ProjectsAPI.SortBy,
		sort: ProjectsAPI.SortDirection,
		page: Int,
		perPage: Int,
		search: String?
	) async throws -> Paginated<[ProjectDTO]> {
		try await api.sendPaginated(
			ProjectsAPI.list(
				orderBy: orderBy,
				sort: sort,
				page: page,
				perPage: perPage,
				search: search,
				publicOnly: true
			)
		)
	}

	public func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
		try await api.sendPaginated(ProjectsAPI.owned(page: page, perPage: perPage, search: search))
	}

	public func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
		try await api.sendPaginated(ProjectsAPI.membership(page: page, perPage: perPage, search: search))
	}

	public func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
		try await api.sendPaginated(ProjectsAPI.starred(page: page, perPage: perPage, search: search))
	}
}
