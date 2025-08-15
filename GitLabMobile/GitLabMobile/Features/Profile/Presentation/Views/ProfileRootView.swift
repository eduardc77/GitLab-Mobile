//
//  ProfileRootView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

struct ProfileRootView: View {
    @Environment(AppEnvironment.self) private var appEnv
    @State private var coordinator = ProfileCoordinator()

    var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            Group {
                switch appEnv.authStore.status {
                case .authenticating:
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                case .authenticated:
                    ProfileView(store: appEnv.profileStore)
                case .unauthenticated:
                    SignedOutView(signIn: appEnv.authStore.signIn)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if appEnv.authStore.status == .authenticated {
                        Button { coordinator.navigate(to: .settings) } label: { Image(systemName: "gearshape") }
                    }
                }
            }
            .navigationDestination(for: ProfileCoordinator.Destination.self) { destination in
                switch destination {
                case .personalProjects:
                    ProjectsListView(service: appEnv.personalProjectsService, scope: .owned)
                case .groups:
                    Text("Groups")
                case .assignedIssues:
                    Text("Assigned Issues")
                case .mergeRequests:
                    Text("Merge Requests")
                case .settings:
                    ProfileSettingsView()
                }
            }
        }
        .environment(coordinator)
        .task { await appEnv.profileStore.loadIfNeeded() }
        .alert("Error", isPresented: .constant(appEnv.authStore.errorMessage != nil), actions: {
            Button("OK") { appEnv.authStore.clearError() }
        }, message: { Text(appEnv.authStore.errorMessage ?? "") })
    }
}
