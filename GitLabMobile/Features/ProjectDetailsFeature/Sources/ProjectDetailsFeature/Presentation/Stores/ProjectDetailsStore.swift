//
//  ProjectDetailsStore.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Observation
import ProjectsDomain

@MainActor
@Observable
public final class ProjectDetailsStore {
    public private(set) var details: ProjectDetails?
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any ProjectsRepository
    private let projectId: Int

    public init(projectId: Int, repository: any ProjectsRepository) {
        self.projectId = projectId
        self.repository = repository
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do {
            details = try await repository.projectDetails(id: projectId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


