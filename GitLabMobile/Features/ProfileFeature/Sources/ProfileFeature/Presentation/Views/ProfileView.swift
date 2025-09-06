//
//  ProfileView.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem

public struct ProfileView: View {
    public var store: ProfileStore

    public var body: some View {
        List {
            if let user = store.user {
                ProfileHeader(user: user)
            } else if store.isLoading {
                LoadingView()
            }

            Section {
                ForEach(ProfileEntry.allCases, id: \.self) { entry in
                    NavigationLink(value: entry.destination) {
                        NavigationRow(
                            systemImage: entry.systemImage,
                            iconColor: entry.iconColor,
                            title: entry.title,
                            subtitle: entry.subtitle
                        )
                    }
                }
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
    }
}
