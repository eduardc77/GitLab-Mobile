//
//  ExploreRootView.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem
import GitLabNavigation
import ProjectsDomain

public struct ExploreRootView: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @Environment(ExploreRouter.self) private var router

    public init() {}

    public var body: some View {
        List {
            Section {
                ForEach(ExploreEntry.allCases, id: \.self) { entry in
                    switch entry {
                    case .projects:
                        NavigationLink(value: ExploreRouter.Destination.projects) {
                            NavigationRow(
                                systemImage: entry.systemImage,
                                iconColor: entry.iconColor,
                                title: entry.title,
                                subtitle: entry.subtitle
                            )
                        }
                    default:
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
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(String(localized: .ExploreL10n.title))
    }
}
