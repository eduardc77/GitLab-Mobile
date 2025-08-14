//
//  ProfileHomeView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ProfileHomeView: View {
    @Bindable public var store: ProfileStore

    public var body: some View {
        List {
            if let user = store.user {
                ProfileHeader(user: user)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            } else if store.isLoading {
                HStack { ProgressView(); Text("Loading profile...").foregroundStyle(.secondary) }
            }

            Section {
                ForEach(ProfileCoordinator.Entry.allCases, id: \.self) { entry in
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
        .listStyle(.plain)
    }
}
