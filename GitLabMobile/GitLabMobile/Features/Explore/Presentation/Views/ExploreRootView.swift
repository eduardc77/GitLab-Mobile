//
//  ExploreRootView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ExploreRootView: View {
    @Environment(AppEnvironment.self) private var appEnv
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
            .navigationTitle("Explore")
            .navigationDestination(for: ExploreCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ExploreProjectsView(repository: appEnv.projectsRepository)
                case .projectDetail(let id):
                    Text("Project #\(id)")
                case .users:
                    Text("Users")
                case .groups:
                    Text("Groups")
                case .topics:
                    Text("Topics")
                case .snippets:
                    Text("Snippets")
                }
            }
        }
    }
}
