//
//  AppTabView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabNavigation

public struct AppTabView: View {
    @Environment(AppRouter.self) private var appRouter
    @State private var selectedTab: AppTab = .explore

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.destination()
                    .tag(tab)
                    .tabItem { tab.label }
            }
        }
    }
}
