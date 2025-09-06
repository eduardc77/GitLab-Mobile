//
//  NavigationProtocols.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Navigation protocols for feature-level routing
//

import ProjectsDomain

/// Protocol for feature-level navigation
public protocol FeatureRouter: Sendable {
    associatedtype Destination: Hashable

    func navigate(to destination: Destination)
    func goBack()
    func goToRoot()

    // Project-specific navigation methods
    func navigateToProjectDetails(_ project: ProjectSummary)
    func navigateToProjectReadme(projectId: Int, projectPath: String)
    func navigateToProjectLicense(projectId: Int, projectPath: String)
    func navigateToProjectFiles(projectId: Int, ref: String?, path: String?)
    func navigateToProjectFile(projectId: Int, path: String, ref: String?, blobSHA: String?)
}

/// Protocol for app-level navigation
public protocol AppNavigationHandler: AnyObject, Sendable {
    /// Navigate to a project by ID
    func navigateToProject(_ projectId: Int, in tab: AppTab)

    /// Navigate to projects list in a tab
    func navigateToProjects(in tab: AppTab)

    /// Unified navigation method for all navigation actions
    func navigate(to action: UnifiedNavigationAction, in tab: AppTab)

    /// Switch to a specific tab
    func switchToTab(_ tab: AppTab)

    /// Go back in a specific tab
    func goBack(in tab: AppTab)

    /// Go to root in a specific tab
    func goToRoot(in tab: AppTab)
}
