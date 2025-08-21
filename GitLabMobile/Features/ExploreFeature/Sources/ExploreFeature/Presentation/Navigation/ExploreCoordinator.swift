//
//  ExploreCoordinator.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
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

        var title: LocalizedStringResource {
            switch self {
            case .projects: return .ExploreDestinationsL10n.projects
            case .users: return .ExploreDestinationsL10n.users
            case .groups: return .ExploreDestinationsL10n.groups
            case .topics: return .ExploreDestinationsL10n.topics
            case .snippets: return .ExploreDestinationsL10n.snippets
            }
        }

        var subtitle: LocalizedStringResource {
            switch self {
            case .projects: return .ExploreEntriesL10n.projectsSubtitle
            case .users: return .ExploreEntriesL10n.usersSubtitle
            case .groups: return .ExploreEntriesL10n.groupsSubtitle
            case .topics: return .ExploreEntriesL10n.topicsSubtitle
            case .snippets: return .ExploreEntriesL10n.snippetsSubtitle
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
            case .groups: return .purple
            case .topics: return .pink
            case .snippets: return .teal
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
