//
//  HomeRootView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

struct HomeRootView: View {
    @Environment(AppEnvironment.self) private var appEnv
    @State private var coordinator = HomeCoordinator()

    var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            Group {
                switch appEnv.authStore.status {
                case .authenticating:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                case .authenticated:
                    yourWorkSection
                case .unauthenticated:
                    SignedOutView(signIn: appEnv.authStore.signIn)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Home")
            .navigationDestination(for: HomeCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ProjectsListView(service: appEnv.personalProjectsService, scope: .combined)
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
            .alert("Error", isPresented: .constant(appEnv.authStore.errorMessage != nil), actions: {
                Button("OK") { appEnv.authStore.clearError() }
            }, message: { Text(appEnv.authStore.errorMessage ?? "") })
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
