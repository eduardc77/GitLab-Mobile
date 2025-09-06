//
//  AppTabExtensions.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Extensions for AppTab to provide UI components specific to the main app
//

import SwiftUI
import GitLabNavigation
import HomeFeature
import ExploreFeature
import ProfileFeature

// Extend the shared AppTab with app-specific UI
extension GitLabNavigation.AppTab {
    @ViewBuilder
    public func destination() -> some View {
        switch self {
        case .home:
            HomeNavigationStack()
        case .explore:
            ExploreNavigationStack()
        case .profile:
            ProfileNavigationStack()
        case .notifications:
            NavigationStack {
                Text("Notifications - Coming Soon")
            }
        }
    }

    public var label: some View {
        Label(title, systemImage: systemImage)
    }
}
