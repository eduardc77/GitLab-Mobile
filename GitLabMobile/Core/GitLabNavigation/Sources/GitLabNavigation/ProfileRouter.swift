//
//  ProfileRouter.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Router for Profile feature navigation
//

import Foundation
import SwiftUICore
import ProjectsDomain

/// Router for Profile feature navigation
@Observable
public final class ProfileRouter: FeatureRouter {
    public typealias Destination = ProfileDestination

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
            appNavigationHandler?.navigateToProjects(in: .profile)
        }
        self.navigateToProject = { [weak appNavigationHandler] projectId in
            appNavigationHandler?.navigateToProject(projectId, in: .profile)
        }
        self.goBackAction = { [weak appNavigationHandler] in
            appNavigationHandler?.goBack(in: .profile)
        }
        self.goToRootAction = { [weak appNavigationHandler] in
            appNavigationHandler?.goToRoot(in: .profile)
        }
    }

    public func navigate(to destination: Destination) {
        switch destination {
        case .personalProjects:
            navigateToProjects()
        case .projectDetail(let project):
            navigateToProject(project.id)
        case .projectReadme, .projectFiles, .projectFile, .projectLicense:
            // These are handled by NavigationLink(value: ...) in views
            break
        case .activity, .contributedProjects, .starredProjects, .groups, .snippets, .followers, .following, .settings:
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
        appNavigationHandler?.navigate(to: .showProjectDetails(project), in: .profile)
    }

    public func navigateToProjectReadme(projectId: Int, projectPath: String) {
        appNavigationHandler?.navigate(to: .showProjectReadme(projectId: projectId, projectPath: projectPath), in: .profile)
    }

    public func navigateToProjectLicense(projectId: Int, projectPath: String) {
        appNavigationHandler?.navigate(to: .showProjectLicense(projectId: projectId, projectPath: projectPath), in: .profile)
    }

    public func navigateToProjectFiles(projectId: Int, ref: String? = nil, path: String? = nil) {
        appNavigationHandler?.navigate(to: .showProjectFiles(projectId: projectId, ref: ref, path: path), in: .profile)
    }

    public func navigateToProjectFile(projectId: Int, path: String, ref: String?, blobSHA: String?) {
        appNavigationHandler?.navigate(
            to: .showProjectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA),
            in: .profile
        )
    }
}
