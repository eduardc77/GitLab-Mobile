//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

@Observable
final class HomeCoordinator {
    var navigationPath = NavigationPath()

    enum Destination: Hashable {
        case projects
        case groups
        case issues
        case mergeRequests
        case todo
        case milestones
        case snippets
        case activity
    }

    enum Entry: CaseIterable {
        case projects, groups, issues, mergeRequests, todo, milestones, snippets, activity

        var title: String {
            switch self {
            case .projects: return "Projects"
            case .groups: return "Groups"
            case .issues: return "Issues"
            case .mergeRequests: return "Merge Requests"
            case .todo: return "To‑Do"
            case .milestones: return "Milestones"
            case .snippets: return "Snippets"
            case .activity: return "Activity"
            }
        }

        var subtitle: String {
            switch self {
            case .projects: return "Owned + membership"
            case .groups: return "Your groups"
            case .issues: return "Assigned to you"
            case .mergeRequests: return "Assigned / review requested"
            case .todo: return "Your GitLab To‑Do"
            case .milestones: return "From your projects and groups"
            case .snippets: return "Your snippets"
            case .activity: return "Recent activity from memberships"
            }
        }

        var systemImage: String {
            switch self {
            case .projects: return "folder.fill"
            case .groups: return "person.2.fill"
            case .issues: return "exclamationmark.circle.fill"
            case .mergeRequests: return "arrow.merge"
            case .todo: return "checklist"
            case .milestones: return "flag.checkered"
            case .snippets: return "scissors"
            case .activity: return "clock.fill"
            }
        }

        var iconColor: Color {
            switch self {
            case .projects: return .blue
            case .groups: return .purple
            case .issues: return .orange
            case .mergeRequests: return .indigo
            case .todo: return .green
            case .milestones: return .gray
            case .snippets: return .teal
            case .activity: return .pink
            }
        }

        var destination: Destination {
            switch self {
            case .projects: return .projects
            case .groups: return .groups
            case .issues: return .issues
            case .mergeRequests: return .mergeRequests
            case .todo: return .todo
            case .milestones: return .milestones
            case .snippets: return .snippets
            case .activity: return .activity
            }
        }
    }
}
