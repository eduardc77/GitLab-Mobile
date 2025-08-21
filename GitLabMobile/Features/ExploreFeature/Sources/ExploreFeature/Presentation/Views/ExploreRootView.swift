//
//  ExploreRootView.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem
import ProjectsDomain

public struct ExploreRootView: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @State private var coordinator = ExploreCoordinator()

    public init() {}

    public var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            List {
                Section {
                    ForEach(ExploreCoordinator.Entry.allCases, id: \.self) { entry in
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
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(String(localized: .ExploreL10n.title))
            .navigationDestination(for: ExploreCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ExploreProjectsView(repository: projectsDependencies.repository)
                case .projectDetail(let id):
                    Text("Project #\(id)")
                case .users:
                    Text(.ExploreDestinationsL10n.users)
                case .groups:
                    Text(.ExploreDestinationsL10n.groups)
                case .topics:
                    Text(.ExploreDestinationsL10n.topics)
                case .snippets:
                    Text(.ExploreDestinationsL10n.snippets)
                }
            }
        }
    }
}
