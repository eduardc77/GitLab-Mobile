//
//  ExploreCoordinator.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import Observation
import ProjectsDomain

@Observable
public final class ExploreCoordinator {
    var navigationPath = NavigationPath()

    public enum Destination: Hashable {
        case projects
        case users
        case groups
        case topics
        case snippets
        case projectDetail(ProjectSummary)
    }

    public enum Entry: CaseIterable {
        case projects, users, groups, topics, snippets

        var title: String {
            switch self {
            case .projects: return "Projects"
            case .users: return "Users"
            case .groups: return "Groups"
            case .topics: return "Topics"
            case .snippets: return "Snippets"
            }
        }

        var subtitle: String {
            switch self {
            case .projects: return "Explore repositories and codebases"
            case .users: return "Discover developers and contributors"
            case .groups: return "Browse organizations and teams"
            case .topics: return "Explore projects by technology and interests"
            case .snippets: return "Explore code snippets from other users"
            }
        }

        var systemImage: String {
            switch self {
            case .projects: return "folder.fill"
            case .users: return "person.2.fill"
            case .groups: return "person.3.fill"
            case .topics: return "tag.fill"
            case .snippets: return "scissors"
            }
        }

        var iconColor: Color {
            switch self {
            case .projects: return .blue
            case .users: return .green
            case .groups: return .orange
            case .topics: return .purple
            case .snippets: return .indigo
            }
        }

        var destination: Destination {
            switch self {
            case .projects: return .projects
            case .users: return .users
            case .groups: return .groups
            case .topics: return .topics
            case .snippets: return .snippets
            }
        }
    }

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }

    func navigateBack() {
        if !navigationPath.isEmpty { navigationPath.removeLast() }
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
