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
                case .unauthenticated:
                    SignedOutView(signIn: appEnv.authStore.signIn)
                case .authenticating:
                    ProgressView("Signing in...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                case .authenticated:
                    ProfileHomeView(store: appEnv.profileStore)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if appEnv.authStore.status == .authenticated {
                        Button {
                            coordinator.navigationPath.append(ProfileCoordinator.Destination.settings)
                        } label: { Image(systemName: "gearshape") }
                    }
                }
            }
            .navigationDestination(for: ProfileCoordinator.Destination.self) { dest in
                switch dest {
                case .personalProjects:
                    Text("Personal Projects")
                case .groups:
                    Text("Groups")
                case .assignedIssues:
                    Text("Assigned Issues")
                case .mergeRequests:
                    Text("Merge Requests")
                case .settings:
                    ProfileSettingsView(signOut: { await appEnv.authStore.signOut() })
                }
            }
        }
        .task { await appEnv.profileStore.loadIfNeeded() }
        .alert("Error", isPresented: .constant(appEnv.authStore.errorMessage != nil), actions: {
            Button("OK") { appEnv.authStore.clearError() }
        }, message: { Text(appEnv.authStore.errorMessage ?? "") })
    }
}
