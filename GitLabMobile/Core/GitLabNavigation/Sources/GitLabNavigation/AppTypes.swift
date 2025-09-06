//
//  AppTypes.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  App-specific types that are shared between main app and features
//

import ProjectsDomain

// MARK: - Unified Navigation Actions

/// Unified navigation actions that represent logical user intents
/// These are independent of which tab the navigation occurs from
public enum UnifiedNavigationAction: Hashable {
    case showProjects
    case showProjectDetails(ProjectSummary)
    case showProjectById(Int)
    case showProjectReadme(projectId: Int, projectPath: String)
    case showProjectLicense(projectId: Int, projectPath: String)
    case showProjectFiles(projectId: Int, ref: String?, path: String?)
    case showProjectFile(projectId: Int, path: String, ref: String?, blobSHA: String?)

    // Feature-specific actions
    case showGroups
    case showIssues
    case showMergeRequests
    case showTodo
    case showMilestones
    case showSnippets
    case showActivity
    case showUsers
    case showTopics
    case showPersonalProjects
    case showContributedProjects
    case showStarredProjects
    case showFollowers
    case showFollowing
    case showSettings
}

// MARK: - App Tab Enum

/// Basic app tabs - shared between features and main app
public enum AppTab: Int, CaseIterable, Identifiable, Hashable, Sendable {
    case home = 0
    case notifications = 1
    case explore = 2
    case profile = 3

    public var id: AppTab { self }

    public var title: String {
        switch self {
        case .home: return "Home"
        case .notifications: return "Notifications"
        case .explore: return "Explore"
        case .profile: return "Profile"
        }
    }

    public var systemImage: String {
        switch self {
        case .home: return "house"
        case .notifications: return "bell"
        case .explore: return "binoculars"
        case .profile: return "person"
        }
    }

    public var index: Int { rawValue }

    public init?(index: Int) {
        self.init(rawValue: index)
    }
}

// MARK: - Home Destination

/// Navigation destinations for the Home tab
public enum HomeDestination: Hashable {
    case projects
    case groups
    case issues
    case mergeRequests
    case todo
    case milestones
    case snippets
    case activity
    case projectDetail(ProjectSummary)
    case projectReadme(projectId: Int, projectPath: String)
    case projectLicense(projectId: Int, projectPath: String)
    case projectFiles(projectId: Int, ref: String?, path: String?)
    case projectFile(projectId: Int, path: String, ref: String?, blobSHA: String?)
}

// MARK: - Explore Destination

/// Navigation destinations for the Explore tab
public enum ExploreDestination: Hashable {
    case projects
    case projectDetail(ProjectSummary)
    case projectId(Int)
    case projectReadme(projectId: Int, projectPath: String)
    case projectLicense(projectId: Int, projectPath: String)
    case projectFiles(projectId: Int, ref: String?, path: String?)
    case projectFile(projectId: Int, path: String, ref: String?, blobSHA: String?)
    case users
    case groups
    case topics
    case snippets
}

// MARK: - Profile Destination

/// Navigation destinations for the Profile tab
public enum ProfileDestination: Hashable {
    case activity
    case personalProjects
    case contributedProjects
    case starredProjects
    case groups
    case snippets
    case followers
    case following
    case settings
    case projectDetail(ProjectSummary)
    case projectReadme(projectId: Int, projectPath: String)
    case projectLicense(projectId: Int, projectPath: String)
    case projectFiles(projectId: Int, ref: String?, path: String?)
    case projectFile(projectId: Int, path: String, ref: String?, blobSHA: String?)
}
