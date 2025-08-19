//
//  HomeRootView.swift
//  HomeFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem
import AuthFeature
import ProjectsDomain
import ProjectsUI
import UserProjectsFeature

public struct HomeRootView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @State private var coordinator = HomeCoordinator()

    public init() {}

    public var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            Group {
                switch authStore.status {
                case .authenticating:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                case .authenticated:
                    yourWorkSection
                case .unauthenticated:
                    SignInView()
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Home")
            .navigationDestination(for: HomeCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ProjectsListView(repository: projectsDependencies.repository, scope: .combined)
                case .groups:
                    Text("Groups")
                case .issues:
                    Text("Issues")
                case .mergeRequests:
                    Text("Merge Requests")
                case .todo:
                    Text("To‑Do")
                case .milestones:
                    Text("Milestones")
                case .snippets:
                    Text("Snippets")
                case .activity:
                    Text("Activity")
                }
            }
            .alert("Error", isPresented: .constant(authStore.errorMessage != nil), actions: {
                Button("OK") { authStore.clearError() }
            }, message: { Text(authStore.errorMessage ?? "") })
        }
    }

    private var yourWorkSection: List<Never, some View> {
        return List {
            Section("Your Work") {
                ForEach(HomeCoordinator.Entry.allCases, id: \.self) { entry in
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
