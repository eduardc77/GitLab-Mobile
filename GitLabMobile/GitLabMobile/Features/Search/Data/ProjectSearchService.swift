//
//  ProjectSearchService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol ProjectSearchServiceProtocol: Sendable {
    func search(_ query: String, page: Int, perPage: Int) async throws -> [ProjectDTO]
}

public struct ProjectSearchService: ProjectSearchServiceProtocol, Sendable {
    private let api: APIClient
    public init(api: APIClient) { self.api = api }

    public func search(_ query: String, page: Int = 1, perPage: Int = 20) async throws -> [ProjectDTO] {
        try await api.send(ProjectsAPI.search(query, page: page, perPage: perPage))
    }
}
