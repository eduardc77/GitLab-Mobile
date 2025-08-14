//
//  ContentView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            ExploreRootView()
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { Text("Notifications") }
                .tabItem { Label("Notifications", systemImage: "bell") }

            NavigationStack { Text("Account") }
                .tabItem { Label("Account", systemImage: "person.circle") }
        }
    }
}
