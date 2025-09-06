//
//  AppRouter.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Concrete implementation of the app's navigation router
//

import SwiftUI
import Observation
import GitLabNavigation
import ProjectsDomain

// Use the AppTab from the GitLabNavigation package
public typealias AppTab = GitLabNavigation.AppTab

@MainActor
@Observable
public final class AppRouter: AppNavigationHandler {
    public var homePath = NavigationPath()
    public var explorePath = NavigationPath()
    public var profilePath = NavigationPath()

    public init() {}

    // MARK: - Unified Navigation

    /// Unified navigation method that handles all navigation actions
    @MainActor
    private func performNavigation(to action: UnifiedNavigationAction, in tab: AppTab) {
        let destination = mapActionToDestination(action, for: tab)

        switch tab {
        case .home:
            homePath.append(destination)
        case .explore:
            explorePath.append(destination)
        case .profile:
            profilePath.append(destination)
        case .notifications:
            // Handle notifications tab if needed
            break
        }
    }

    /// Unified navigation method that handles all navigation actions
    public nonisolated func navigate(to action: UnifiedNavigationAction, in tab: AppTab) {
        Task { @MainActor in
            self.performNavigation(to: action, in: tab)
        }
    }

    /// Maps unified navigation actions to tab-specific destinations
    private func mapActionToDestination(_ action: UnifiedNavigationAction, for tab: AppTab) -> any Hashable {
        // Simple mappings using dictionaries for O(1) lookup
        if let destination = mapSimpleDestination(action, for: tab) {
            return destination
        }

        // Complex mappings requiring logic
        return mapComplexDestination(action, for: tab)
    }

    /// Handles simple destination mappings with dictionaries
    private func mapSimpleDestination(_ action: UnifiedNavigationAction, for tab: AppTab) -> (any Hashable)? {
        let simpleMappings: [UnifiedNavigationAction: [AppTab: any Hashable]] = [
            .showProjects: [
                .home: HomeDestination.projects,
                .explore: ExploreDestination.projects,
                .profile: ProfileDestination.personalProjects,
            ],
            .showGroups: [
                .home: HomeDestination.groups,
                .explore: ExploreDestination.groups,
                .profile: ProfileDestination.groups,
            ],
            .showIssues: [.home: HomeDestination.issues],
            .showMergeRequests: [.home: HomeDestination.mergeRequests],
            .showTodo: [.home: HomeDestination.todo],
            .showMilestones: [.home: HomeDestination.milestones],
            .showSnippets: [
                .home: HomeDestination.snippets,
                .explore: ExploreDestination.snippets,
                .profile: ProfileDestination.snippets,
            ],
            .showActivity: [
                .home: HomeDestination.activity,
                .profile: ProfileDestination.activity,
            ],
            .showUsers: [.explore: ExploreDestination.users],
            .showTopics: [.explore: ExploreDestination.topics],
            .showPersonalProjects: [.profile: ProfileDestination.personalProjects],
            .showContributedProjects: [.profile: ProfileDestination.contributedProjects],
            .showStarredProjects: [.profile: ProfileDestination.starredProjects],
            .showFollowers: [.profile: ProfileDestination.followers],
            .showFollowing: [.profile: ProfileDestination.following],
            .showSettings: [.profile: ProfileDestination.settings],
        ]

        return simpleMappings[action]?[tab]
    }

    /// Handles complex destination mappings requiring logic
    private func mapComplexDestination(_ action: UnifiedNavigationAction, for tab: AppTab) -> any Hashable {
        switch action {
        case .showProjectDetails(let project):
            return mapProjectDetails(project, for: tab)
        case .showProjectById(let projectId):
            return mapProjectById(projectId, for: tab)
        case .showProjectReadme(let projectId, let projectPath):
            return mapProjectReadme(projectId: projectId, projectPath: projectPath, for: tab)
        case .showProjectLicense(let projectId, let projectPath):
            return mapProjectLicense(projectId: projectId, projectPath: projectPath, for: tab)
        case .showProjectFiles(let projectId, let ref, let path):
            return mapProjectFiles(projectId: projectId, ref: ref, path: path, for: tab)
        case .showProjectFile(let projectId, let path, let ref, let blobSHA):
            return mapProjectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA, for: tab)
        default:
            return HomeDestination.projects // Safe fallback
        }
    }

    private func mapProjectDetails(_ project: ProjectSummary, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectDetail(project)
        case .explore:
            return ExploreDestination.projectDetail(project)
        case .profile:
            return ProfileDestination.projectDetail(project)
        case .notifications:
            return HomeDestination.projectDetail(project) // fallback
        }
    }

    private func mapProjectById(_ projectId: Int, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectDetail(ProjectSummary.placeholder(id: projectId))
        case .explore:
            return ExploreDestination.projectId(projectId)
        case .profile:
            return ProfileDestination.projectDetail(ProjectSummary.placeholder(id: projectId))
        case .notifications:
            return HomeDestination.projectDetail(ProjectSummary.placeholder(id: projectId))
        }
    }

    private func mapProjectReadme(projectId: Int, projectPath: String, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectReadme(projectId: projectId, projectPath: projectPath)
        case .explore:
            return ExploreDestination.projectReadme(projectId: projectId, projectPath: projectPath)
        case .profile:
            return ProfileDestination.projectReadme(projectId: projectId, projectPath: projectPath)
        case .notifications:
            return HomeDestination.projectReadme(projectId: projectId, projectPath: projectPath)
        }
    }

    private func mapProjectLicense(projectId: Int, projectPath: String, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectLicense(projectId: projectId, projectPath: projectPath)
        case .explore:
            return ExploreDestination.projectLicense(projectId: projectId, projectPath: projectPath)
        case .profile:
            return ProfileDestination.projectLicense(projectId: projectId, projectPath: projectPath)
        case .notifications:
            return HomeDestination.projectLicense(projectId: projectId, projectPath: projectPath)
        }
    }

    private func mapProjectFiles(projectId: Int, ref: String?, path: String?, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectFiles(projectId: projectId, ref: ref, path: path)
        case .explore:
            return ExploreDestination.projectFiles(projectId: projectId, ref: ref, path: path)
        case .profile:
            return ProfileDestination.projectFiles(projectId: projectId, ref: ref, path: path)
        case .notifications:
            return HomeDestination.projectFiles(projectId: projectId, ref: ref, path: path)

        }
    }

    private func mapProjectFile(projectId: Int, path: String, ref: String?, blobSHA: String?, for tab: AppTab) -> any Hashable {
        switch tab {
        case .home:
            return HomeDestination.projectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA)
        case .explore:
            return ExploreDestination.projectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA)
        case .profile:
            return ProfileDestination.projectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA)
        case .notifications:
            return HomeDestination.projectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA)
        }
    }

    // MARK: - AppNavigationHandler Implementation

    @MainActor
    private func performNavigateToProject(_ projectId: Int, in tab: AppTab) {
        switch tab {
        case .home:
            homePath.append(HomeDestination.projectDetail(ProjectSummary.placeholder(id: projectId)))
        case .explore:
            explorePath.append(ExploreDestination.projectId(projectId))
        case .profile:
            profilePath.append(ProfileDestination.projectDetail(ProjectSummary.placeholder(id: projectId)))
        case .notifications:
            break
        }
    }

    public nonisolated func navigateToProject(_ projectId: Int, in tab: AppTab) {
        Task { @MainActor in
            self.performNavigateToProject(projectId, in: tab)
        }
    }

    @MainActor
    private func performNavigateToProjects(in tab: AppTab) {
        switch tab {
        case .home:
            homePath.append(HomeDestination.projects)
        case .explore:
            explorePath.append(ExploreDestination.projects)
        case .profile:
            profilePath.append(ProfileDestination.personalProjects)
        case .notifications:
            break
        }
    }

    public nonisolated func navigateToProjects(in tab: AppTab) {
        Task { @MainActor in
            self.performNavigateToProjects(in: tab)
        }
    }

    @MainActor
    private func performSwitchToTab(_ tab: AppTab) {
        // This is handled by AppTabView's selectedTab state
    }

    public nonisolated func switchToTab(_ tab: AppTab) {
        Task { @MainActor in
            self.performSwitchToTab(tab)
        }
    }

    @MainActor
    private func performGoBack(in tab: AppTab) {
        switch tab {
        case .home:
            if !homePath.isEmpty { homePath.removeLast() }
        case .explore:
            if !explorePath.isEmpty { explorePath.removeLast() }
        case .profile:
            if !profilePath.isEmpty { profilePath.removeLast() }
        case .notifications:
            break
        }
    }

    public nonisolated func goBack(in tab: AppTab) {
        Task { @MainActor in
            self.performGoBack(in: tab)
        }
    }

    @MainActor
    private func performGoToRoot(in tab: AppTab) {
        switch tab {
        case .home:
            homePath.removeLast(homePath.count)
        case .explore:
            explorePath.removeLast(explorePath.count)
        case .profile:
            profilePath.removeLast(profilePath.count)
        case .notifications:
            break
        }
    }

    public nonisolated func goToRoot(in tab: AppTab) {
        Task { @MainActor in
            self.performGoToRoot(in: tab)
        }
    }

    // MARK: - Deep Link Handling

    public func handleDeepLink(_ deepLink: AppDeepLink) -> DeepLinkResult {
        switch deepLink {
        case .tab(let tabIndex):
            if let tab = AppTab(rawValue: tabIndex) {
                return .switchToTab(tab)
            }
            return .invalid
        case .projectDetails(let projectId):
            return .navigateToProject(projectId: projectId, tab: .explore)
        }
    }
}
