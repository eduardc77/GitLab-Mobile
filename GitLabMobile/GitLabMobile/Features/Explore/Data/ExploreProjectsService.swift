//
//  ExploreProjectsService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

public protocol ExploreProjectsServiceProtocol: Sendable {
    func getList(
        orderBy: ProjectsAPI.SortBy,
        sort: ProjectsAPI.SortDirection,
        page: Int,
        perPage: Int,
        search: String?
    ) async throws -> Paginated<[ProjectSummary]>
}

public struct ExploreProjectsService: ExploreProjectsServiceProtocol {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getList(
        orderBy: ProjectsAPI.SortBy,
        sort: ProjectsAPI.SortDirection,
        page: Int,
        perPage: Int,
        search: String?
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.list(
            orderBy: orderBy,
            sort: sort,
            page: page,
            perPage: perPage,
            search: search,
            publicOnly: true
        )
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }
}
