//
//  ExploreStrings.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// Centralized localized strings for Explore feature.
/// Typed, namespaced LocalizedStringResource accessors with dot-notation.
/// Use String(localized: .Explore.title) in code, or Text(.Explore.title) and Label(String(localized: .Explore.Projects.emptyTitle) in SwiftUI.
extension LocalizedStringResource {
    enum ExploreL10n {
        static let title = LocalizedStringResource(
            "explore.title",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ExploreProjectsL10n {
        static let title = LocalizedStringResource(
            "explore.projects.title",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let recentSearches = LocalizedStringResource(
            "explore.projects.recent_searches",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let loading = LocalizedStringResource(
            "explore.projects.loading",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let emptyTitle = LocalizedStringResource(
            "explore.projects.empty.title",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let emptyDescription = LocalizedStringResource(
            "explore.projects.empty.description",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let sortBy = LocalizedStringResource(
            "explore.projects.sort_by",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let direction = LocalizedStringResource(
            "explore.projects.direction",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ExploreAlertsL10n {
        static let errorTitle = LocalizedStringResource(
            "explore.alerts.error.title",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let okButtonTitle = LocalizedStringResource(
            "explore.alerts.ok",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ExploreDestinationsL10n {
        static let projects = LocalizedStringResource(
            "explore.destinations.projects",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let users = LocalizedStringResource(
            "explore.destinations.users",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groups = LocalizedStringResource(
            "explore.destinations.groups",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let topics = LocalizedStringResource(
            "explore.destinations.topics",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippets = LocalizedStringResource(
            "explore.destinations.snippets",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ExploreEntriesL10n {
        static let projectsSubtitle = LocalizedStringResource(
            "explore.entries.projects.subtitle",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let usersSubtitle = LocalizedStringResource(
            "explore.entries.users.subtitle",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groupsSubtitle = LocalizedStringResource(
            "explore.entries.groups.subtitle",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let topicsSubtitle = LocalizedStringResource(
            "explore.entries.topics.subtitle",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippetsSubtitle = LocalizedStringResource(
            "explore.entries.snippets.subtitle",
            table: "Explore",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
