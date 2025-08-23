//
//  AppTab.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import HomeFeature
import ExploreFeature
import ProfileFeature
import ProjectsDomain
import ProjectDetailsFeature

enum AppTab: CaseIterable, Identifiable, Hashable {
    case home
    case notifications
    case explore
    case profile

    var id: AppTab { self }
}

extension AppTab {
    @ViewBuilder
    var label: some View {
        switch self {
        case .home:
            Label(String(localized: .AppTabsL10n.home), systemImage: "house")
        case .notifications:
            Label(String(localized: .AppTabsL10n.notifications), systemImage: "bell")
        case .explore:
            Label(String(localized: .AppTabsL10n.explore), systemImage: "binoculars")
        case .profile:
            Label(String(localized: .AppTabsL10n.profile), systemImage: "person")
        }
    }

    @ViewBuilder
    func destination() -> some View {
        switch self {
        case .home:
            HomeNavigationStack()
        case .notifications:
            NavigationStack { Text(String(localized: .AppTabsL10n.notifications)) }
        case .explore:
            ExploreNavigationStack()
        case .profile:
            ProfileNavigationStack()
        }
    }
}
