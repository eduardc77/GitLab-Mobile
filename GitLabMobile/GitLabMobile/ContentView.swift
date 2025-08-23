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
            ForEach(AppTab.allCases) { tab in
                tab.destination()
                    .tabItem { tab.label }
            }
        }
    }
}
