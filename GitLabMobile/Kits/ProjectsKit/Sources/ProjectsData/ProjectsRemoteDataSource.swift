//
//  ProjectsRemoteDataSource.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork
import ProjectsDomain

extension ProjectDTO {
    func toDomain() -> ProjectSummary {
        ProjectSummary(
            id: id,
            name: name,
            pathWithNamespace: pathWithNamespace,
            description: description,
            starCount: starCount ?? 0,
            forksCount: forksCount ?? 0,
            avatarUrl: avatarUrl.flatMap(URL.init),
            webUrl: URL(string: webUrl) ?? URL(string: "https://gitlab.com") ?? URL(fileURLWithPath: "/"),
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

	func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
	func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
	func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
	func fetchPersonalContributed(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>

	func fetchProjectDetails(id: Int) async throws -> ProjectDTO
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

	public func fetchPersonalOwned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsEndpoints.owned(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
		return Paginated(items: dto.items.map { $0.toDomain() }, pageInfo: dto.pageInfo)
	}

    public func fetchPersonalMembership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsEndpoints.membership(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: dto.items.map { $0.toDomain() }, pageInfo: dto.pageInfo)
    }

    public func fetchPersonalStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsEndpoints.starred(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: dto.items.map { $0.toDomain() }, pageInfo: dto.pageInfo)
    }

    public func fetchPersonalContributed(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsEndpoints.contributed(
            page: page,
            perPage: perPage,
            search: search
        )
        let dto: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: dto.items.map { $0.toDomain() }, pageInfo: dto.pageInfo)
    }

	public func fetchProjectDetails(id: Int) async throws -> ProjectDTO {
		try await api.send(ProjectsEndpoints.project(id: id))
	}
}
