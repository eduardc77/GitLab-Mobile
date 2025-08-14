//
//  ExploreProjectsService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol ExploreProjectsServiceProtocol: Sendable {
    func getTrending(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func getMostStarred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func getActive(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func getInactive(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func getAll(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func getList(
        orderBy: ProjectsAPI.OrderBy,
        page: Int,
        perPage: Int,
        search: String?,
        publicOnly: Bool
    ) async throws -> Paginated<[ProjectSummary]>
}

public struct ExploreProjectsService: ExploreProjectsServiceProtocol {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getTrending(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.trending(page: page, perPage: perPage, search: search)
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    public func getMostStarred(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.mostStarred(page: page, perPage: perPage, search: search)
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    public func getActive(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.active(page: page, perPage: perPage, search: search)
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    public func getInactive(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.inactive(page: page, perPage: perPage, search: search)
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    public func getAll(
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.all(page: page, perPage: perPage, search: search)
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    public func getList(
        orderBy: ProjectsAPI.OrderBy,
        page: Int,
        perPage: Int,
        search: String?,
        publicOnly: Bool
    ) async throws -> Paginated<[ProjectSummary]> {
        let endpoint = ProjectsAPI.list(
            orderBy: orderBy,
            page: page,
            perPage: perPage,
            search: search,
            publicOnly: publicOnly
        )
        let pagedDTOs: Paginated<[ProjectDTO]> = try await api.sendPaginated(endpoint)
        return Paginated(items: pagedDTOs.items.map { $0.toDomain() }, pageInfo: pagedDTOs.pageInfo)
    }

    // MARK: - Helpers removed in favor of APIClient.sendPaginated
}
