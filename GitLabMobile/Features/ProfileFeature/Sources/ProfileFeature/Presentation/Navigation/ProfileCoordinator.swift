//
//  ProfileCoordinator.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

@Observable
final class ProfileCoordinator {
    var navigationPath = NavigationPath()

    enum Destination: Hashable {
        case personalProjects
        case groups
        case assignedIssues
        case mergeRequests
        case settings
    }

    enum Entry: CaseIterable {
        case personalProjects, groups, assignedIssues, mergeRequests

        var title: String {
            switch self {
            case .personalProjects: return "Personal Projects"
            case .groups: return "Groups"
            case .assignedIssues: return "Assigned Issues"
            case .mergeRequests: return "Merge Requests"
            }
        }

        var subtitle: String {
            switch self {
            case .personalProjects: return "Projects you own or maintain"
            case .groups: return "Groups you are a member of"
            case .assignedIssues: return "Issues assigned to you or created by you"
            case .mergeRequests: return "Merge requests you created or need to review"
            }
        }

        var systemImage: String {
            switch self {
            case .personalProjects: return "folder.fill"
            case .groups: return "person.2.fill"
            case .assignedIssues: return "exclamationmark.circle.fill"
            case .mergeRequests: return "arrow.merge"
            }
        }

        var iconColor: Color {
            switch self {
            case .personalProjects: return .blue
            case .groups: return .green
            case .assignedIssues: return .orange
            case .mergeRequests: return .purple
            }
        }

        var destination: Destination {
            switch self {
            case .personalProjects: return .personalProjects
            case .groups: return .groups
            case .assignedIssues: return .assignedIssues
            case .mergeRequests: return .mergeRequests
            }
        }
    }

    // MARK: - Navigation API

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }

    func navigateBack() {
        navigationPath.removeLast()
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
