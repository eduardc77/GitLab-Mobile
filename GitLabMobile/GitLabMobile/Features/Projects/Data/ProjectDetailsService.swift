//
//  ProjectDetailsService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol ProjectDetailsServiceProtocol: Sendable {
    func getProject(id: Int) async throws -> ProjectDTO
}

public struct ProjectDetailsService: ProjectDetailsServiceProtocol {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func getProject(id: Int) async throws -> ProjectDTO {
        try await api.send(ProjectsEndpoints.project(id: id))
    }
}
