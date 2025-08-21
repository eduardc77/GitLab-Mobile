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
        case activity
        case groups
        case contributedProjects
        case personalProjects
        case starredProjects
        case snippets
        case followers
        case following
        case settings
    }

    enum Entry: CaseIterable {
        case activity, personalProjects, contributedProjects, starredProjects, groups, snippets, followers, following

        var title: LocalizedStringResource {
            switch self {
            case .activity: return .ProfileDestinationsL10n.activity
            case .personalProjects: return .ProfileDestinationsL10n.personalProjects
            case .contributedProjects: return .ProfileDestinationsL10n.contributedProjects
            case .starredProjects: return .ProfileDestinationsL10n.starredProjects
            case .groups: return .ProfileDestinationsL10n.groups
            case .snippets: return .ProfileDestinationsL10n.snippets
            case .followers: return .ProfileDestinationsL10n.followers
            case .following: return .ProfileDestinationsL10n.following
            }
        }

        var subtitle: LocalizedStringResource {
            switch self {
            case .activity: return .ProfileEntriesL10n.activitySubtitle
            case .personalProjects: return .ProfileEntriesL10n.personalProjectsSubtitle
            case .contributedProjects: return .ProfileEntriesL10n.contributedProjectsSubtitle
            case .starredProjects: return .ProfileEntriesL10n.starredProjectsSubtitle
            case .groups: return .ProfileEntriesL10n.groupsSubtitle
            case .snippets: return .ProfileEntriesL10n.snippetsSubtitle
            case .followers: return .ProfileEntriesL10n.followersSubtitle
            case .following: return .ProfileEntriesL10n.followingSubtitle
            }
        }

        var systemImage: String {
            switch self {
            case .activity: return "clock.fill"
            case .personalProjects: return "folder.fill"
            case .contributedProjects: return "tray.and.arrow.up"
            case .starredProjects: return "star.fill"
            case .groups: return "person.3.fill"
            case .snippets: return "scissors"
            case .followers: return "person.2.fill"
            case .following: return "person.fill"
            }
        }

        var iconColor: Color {
            switch self {
            case .activity: return .pink
            case .groups: return .purple
            case .contributedProjects: return .teal
            case .personalProjects: return .blue
            case .starredProjects: return .yellow
            case .snippets: return .indigo
            case .followers: return .green
            case .following: return .mint
            }
        }

        var destination: Destination {
            switch self {
            case .activity: return .activity
            case .groups: return .groups
            case .contributedProjects: return .contributedProjects
            case .personalProjects: return .personalProjects
            case .starredProjects: return .starredProjects
            case .snippets: return .snippets
            case .followers: return .followers
            case .following: return .following
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
