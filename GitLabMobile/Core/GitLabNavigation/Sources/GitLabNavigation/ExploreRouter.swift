//
//  ExploreRouter.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Router for Explore feature navigation
//

import Foundation
import SwiftUICore
import ProjectsDomain

/// Router for Explore feature navigation
@Observable
public final class ExploreRouter: FeatureRouter {
    public typealias Destination = ExploreDestination

    @ObservationIgnored
    private let navigateToProjects: @Sendable () -> Void

    @ObservationIgnored
    private let navigateToProject: @Sendable (Int) -> Void

    @ObservationIgnored
    private let goBackAction: @Sendable () -> Void

    @ObservationIgnored
    private let goToRootAction: @Sendable () -> Void

    @ObservationIgnored
    private let appNavigationHandler: AppNavigationHandler?

    public init(appNavigationHandler: AppNavigationHandler?) {
        self.appNavigationHandler = appNavigationHandler
        self.navigateToProjects = { [weak appNavigationHandler] in
            appNavigationHandler?.navigateToProjects(in: .explore)
        }
        self.navigateToProject = { [weak appNavigationHandler] projectId in
            appNavigationHandler?.navigateToProject(projectId, in: .explore)
        }
        self.goBackAction = { [weak appNavigationHandler] in
            appNavigationHandler?.goBack(in: .explore)
        }
        self.goToRootAction = { [weak appNavigationHandler] in
            appNavigationHandler?.goToRoot(in: .explore)
        }
    }

    public func navigate(to destination: Destination) {
        switch destination {
        case .projects:
            navigateToProjects()
        case .projectDetail(let project):
            navigateToProject(project.id)
        case .projectId(let projectId):
            navigateToProject(projectId)
        case .projectReadme, .projectFiles, .projectFile, .projectLicense:
            // These are handled by NavigationLink(value: ...) in views
            break
        case .users, .groups, .topics, .snippets:
            // Handle feature-specific navigation that doesn't need app-level routing
            break
        }
    }

    public func goBack() {
        goBackAction()
    }

    public func goToRoot() {
        goToRootAction()
    }

    // MARK: - Unified Navigation Methods

    public func navigateToProjectDetails(_ project: ProjectSummary) {
        appNavigationHandler?.navigate(to: .showProjectDetails(project), in: .explore)
    }

    public func navigateToProjectReadme(projectId: Int, projectPath: String) {
        appNavigationHandler?.navigate(to: .showProjectReadme(projectId: projectId, projectPath: projectPath), in: .explore)
    }

    public func navigateToProjectLicense(projectId: Int, projectPath: String) {
        appNavigationHandler?.navigate(to: .showProjectLicense(projectId: projectId, projectPath: projectPath), in: .explore)
    }

    public func navigateToProjectFiles(projectId: Int, ref: String? = nil, path: String? = nil) {
        appNavigationHandler?.navigate(to: .showProjectFiles(projectId: projectId, ref: ref, path: path), in: .explore)
    }

    public func navigateToProjectFile(projectId: Int, path: String, ref: String?, blobSHA: String?) {
        appNavigationHandler?.navigate(
            to: .showProjectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA),
            in: .explore
        )
    }
}
