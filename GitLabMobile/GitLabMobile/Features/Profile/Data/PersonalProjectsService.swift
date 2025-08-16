//
//  PersonalProjectsService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol PersonalProjectsServiceProtocol: Sendable {
    func owned(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func starred(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
    func membership(page: Int, perPage: Int, search: String?) async throws -> Paginated<[ProjectSummary]>
}

public struct PersonalProjectsService: PersonalProjectsServiceProtocol {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func owned(page: Int = 1, perPage: Int = 20, search: String? = nil) async throws -> Paginated<[ProjectSummary]> {
        try await api.sendPaginated(ProjectsAPI.owned(page: page, perPage: perPage, search: search))
    }

    public func starred(page: Int = 1, perPage: Int = 20, search: String? = nil) async throws -> Paginated<[ProjectSummary]> {
        try await api.sendPaginated(ProjectsAPI.starred(page: page, perPage: perPage, search: search))
    }

    public func membership(page: Int = 1, perPage: Int = 20, search: String? = nil) async throws -> Paginated<[ProjectSummary]> {
        try await api.sendPaginated(ProjectsAPI.membership(page: page, perPage: perPage, search: search))
    }
}
