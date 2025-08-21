//
//  ProfileRootView.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import AuthFeature
import UserProjectsFeature
import ProjectsUI

import ProjectsDomain

public struct ProfileRootView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProfileStore.self) private var profileStore
    @State private var coordinator = ProfileCoordinator()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ProjectsDependencies.self) private var projectsDependencies

    public init() {}

    public var body: some View {
        NavigationStack(path: Bindable(coordinator).navigationPath) {
            Group {
                switch authStore.status {
                case .authenticating:
                    ProgressView(String(localized: .ProfileLoadingL10n.profile))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                case .authenticated:
                    ProfileView(store: profileStore)
                case .unauthenticated:
                    SignInView()
                }
            }
            .navigationTitle(String(localized: .ProfileL10n.title))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if authStore.status == .authenticated {
                        Button { coordinator.navigate(to: .settings) } label: { Image(systemName: "gearshape") }
                    }
                }
            }
            .navigationDestination(for: ProfileCoordinator.Destination.self) { destination in
                switch destination {
                case .activity:
                    Text(.ProfileDestinationsL10n.activity)
                case .groups:
                    Text(.ProfileDestinationsL10n.groups)
                case .contributedProjects:
                    Text(.ProfileDestinationsL10n.contributedProjects)
                case .personalProjects:
                    ProjectsListView(repository: projectsDependencies.repository, scope: .owned)
                case .starredProjects:
                    Text(.ProfileDestinationsL10n.starredProjects)
                case .snippets:
                    Text(.ProfileDestinationsL10n.snippets)
                case .followers:
                    Text(.ProfileDestinationsL10n.followers)
                case .following:
                    Text(.ProfileDestinationsL10n.following)
                case .settings:
                    ProfileSettingsView()
                }
            }
        }
        .environment(coordinator)
        .task { await profileStore.loadIfNeeded() }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task { await profileStore.onAppForegrounded() }
            }
        }
        .alert(String(
            localized: .ProfileAlertsL10n.error),
               isPresented: .constant(authStore.errorMessage != nil),
               actions: {
            Button(String(localized: .ProfileAlertsL10n.okButtonTitle)) {
                authStore.clearError()
            }
        }, message: {
            Text(authStore.errorMessage ?? "")
        })
    }
}
