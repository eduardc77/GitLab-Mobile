//
//  HomeEntry.swift
//  HomeFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabNavigation

public enum HomeEntry: CaseIterable {
    case projects, groups, issues, mergeRequests, todo, milestones, snippets, activity
}

extension HomeEntry {
    var title: LocalizedStringResource {
        switch self {
        case .projects: return .HomeDestinationsL10n.projects
        case .groups: return .HomeDestinationsL10n.groups
        case .issues: return .HomeDestinationsL10n.issues
        case .mergeRequests: return .HomeDestinationsL10n.mergeRequests
        case .todo: return .HomeDestinationsL10n.todo
        case .milestones: return .HomeDestinationsL10n.milestones
        case .snippets: return .HomeDestinationsL10n.snippets
        case .activity: return .HomeDestinationsL10n.activity
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .projects: return .HomeEntriesL10n.projectsSubtitle
        case .groups: return .HomeEntriesL10n.groupsSubtitle
        case .issues: return .HomeEntriesL10n.issuesSubtitle
        case .mergeRequests: return .HomeEntriesL10n.mergeRequestsSubtitle
        case .todo: return .HomeEntriesL10n.todoSubtitle
        case .milestones: return .HomeEntriesL10n.milestonesSubtitle
        case .snippets: return .HomeEntriesL10n.snippetsSubtitle
        case .activity: return .HomeEntriesL10n.activitySubtitle
        }
    }

    var systemImage: String {
        switch self {
        case .projects: return "folder.fill"
        case .groups: return "person.3.fill"
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

    var destination: HomeRouter.Destination {
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
