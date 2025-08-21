//
//  ContentView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import HomeFeature
import ExploreFeature
import ProfileFeature

struct ContentView: View {
    var body: some View {
        TabView {
            HomeRootView()
                .tabItem { Label(String(localized: .AppTabsL10n.home), systemImage: "house") }

            NavigationStack { Text(String(localized: .AppTabsL10n.notifications)) }
                .tabItem { Label(String(localized: .AppTabsL10n.notifications), systemImage: "bell") }

            ExploreRootView()
                .tabItem { Label(String(localized: .AppTabsL10n.explore), systemImage: "binoculars") }

            ProfileRootView()
                .tabItem { Label(String(localized: .AppTabsL10n.profile), systemImage: "person") }
        }
    }
}
