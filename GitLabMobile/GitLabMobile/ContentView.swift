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
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { Text("Notifications") }
                .tabItem { Label("Notifications", systemImage: "bell") }

            ExploreRootView()
                .tabItem { Label("Explore", systemImage: "binoculars") }

            ProfileRootView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
