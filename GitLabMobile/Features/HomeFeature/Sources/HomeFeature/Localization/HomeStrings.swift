//
//  HomeStrings.swift
//  HomeFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

extension LocalizedStringResource {
    enum HomeL10n {
        static let title = LocalizedStringResource(
            "home.title",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum HomeSectionsL10n {
        static let yourWork = LocalizedStringResource(
            "home.sections.your_work",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum HomeAlertsL10n {
        static let error = LocalizedStringResource(
            "home.alerts.error",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let okButtonTitle = LocalizedStringResource(
            "home.alerts.ok",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum HomeDestinationsL10n {
        static let projects = LocalizedStringResource(
            "home.destinations.projects",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groups = LocalizedStringResource(
            "home.destinations.groups",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let issues = LocalizedStringResource(
            "home.destinations.issues",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let mergeRequests = LocalizedStringResource(
            "home.destinations.merge_requests",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let todo = LocalizedStringResource(
            "home.destinations.todo",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let milestones = LocalizedStringResource(
            "home.destinations.milestones",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippets = LocalizedStringResource(
            "home.destinations.snippets",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let activity = LocalizedStringResource(
            "home.destinations.activity",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum HomeEntriesL10n {
        // Refined, concise subtitles
        static let projectsSubtitle = LocalizedStringResource(
            "home.entries.projects.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groupsSubtitle = LocalizedStringResource(
            "home.entries.groups.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let issuesSubtitle = LocalizedStringResource(
            "home.entries.issues.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let mergeRequestsSubtitle = LocalizedStringResource(
            "home.entries.merge_requests.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let todoSubtitle = LocalizedStringResource(
            "home.entries.todo.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let milestonesSubtitle = LocalizedStringResource(
            "home.entries.milestones.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippetsSubtitle = LocalizedStringResource(
            "home.entries.snippets.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let activitySubtitle = LocalizedStringResource(
            "home.entries.activity.subtitle",
            table: "Home",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
