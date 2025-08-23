//
//  ProfileStrings.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

extension LocalizedStringResource {
    enum ProfileL10n { // screen title only
        static let title = LocalizedStringResource(
            "profile.title",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileLoadingL10n {
        static let profile = LocalizedStringResource(
            "profile.loading",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileDestinationsL10n {
        static let activity = LocalizedStringResource(
            "profile.destinations.activity",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let personalProjects = LocalizedStringResource(
            "profile.destinations.personal_projects",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groups = LocalizedStringResource(
            "profile.destinations.groups",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let contributedProjects = LocalizedStringResource(
            "profile.destinations.contributed_projects",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let starredProjects = LocalizedStringResource(
            "profile.destinations.starred_projects",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippets = LocalizedStringResource(
            "profile.destinations.snippets",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let followers = LocalizedStringResource(
            "profile.destinations.followers",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let following = LocalizedStringResource(
            "profile.destinations.following",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let settings = LocalizedStringResource(
            "profile.destinations.settings",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileEntriesL10n {
        static let activitySubtitle = LocalizedStringResource(
            "profile.entries.activity.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let personalProjectsSubtitle = LocalizedStringResource(
            "profile.entries.personal_projects.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let groupsSubtitle = LocalizedStringResource(
            "profile.entries.groups.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let contributedProjectsSubtitle = LocalizedStringResource(
            "profile.entries.contributed_projects.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let starredProjectsSubtitle = LocalizedStringResource(
            "profile.entries.starred_projects.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let snippetsSubtitle = LocalizedStringResource(
            "profile.entries.snippets.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let followersSubtitle = LocalizedStringResource(
            "profile.entries.followers.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let followingSubtitle = LocalizedStringResource(
            "profile.entries.following.subtitle",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileAlertsL10n {
        static let error = LocalizedStringResource(
            "profile.alerts.error",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let okButtonTitle = LocalizedStringResource(
            "profile.alerts.ok",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileSettingsL10n {
        static let accountSettings = LocalizedStringResource(
            "profile.settings.account_settings",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let signOut = LocalizedStringResource(
            "profile.settings.sign_out",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }

    enum ProfileHeaderL10n {
        static let memberSince = LocalizedStringResource(
            "profile.header.member_since",
            table: "Profile",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
