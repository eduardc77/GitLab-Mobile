//
//  ExploreEntry+Presentation.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabNavigation

public enum ExploreEntry: CaseIterable {
    case projects, users, groups, topics, snippets
}

extension ExploreEntry {
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

    var destination: ExploreDestination {
        switch self {
        case .projects: return .projects
        case .users: return .users
        case .groups: return .groups
        case .topics: return .topics
        case .snippets: return .snippets
        }
    }
}
