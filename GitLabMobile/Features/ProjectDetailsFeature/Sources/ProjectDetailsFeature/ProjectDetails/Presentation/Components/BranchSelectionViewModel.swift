//
//  BranchSelectionViewModel.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation
import ProjectsDomain
import GitLabLogging

@MainActor
@Observable
final class BranchSelectionViewModel {
    var branches: [Branch] = []
    var isLoading = false
    var error: Error?

    @ObservationIgnored
    private let projectId: Int

    @ObservationIgnored
    private let repository: any ProjectsRepository

    init(projectId: Int, repository: any ProjectsRepository) {
        self.projectId = projectId
        self.repository = repository
    }

    func loadBranches() async {
        isLoading = true
        error = nil

        do {
            let branches = try await repository.branches(projectId: projectId)
            self.branches = branches
            AppLog.projects.debug("Successfully loaded \(branches.count) branches for project \(self.projectId)")
        } catch {
            self.error = error
            AppLog.projects.debug("Failed to load branches for project \(self.projectId): \(error.localizedDescription)")
        }

        isLoading = false
    }
}
