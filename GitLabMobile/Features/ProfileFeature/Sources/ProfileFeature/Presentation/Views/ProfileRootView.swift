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
import GitLabNavigation
import ProjectsDomain

public struct ProfileRootView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProfileStore.self) private var profileStore
    private let router = ProfileRouter()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ProjectsDependencies.self) private var projectsDependencies

    public init() {}

    public var body: some View {
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
                    NavigationLink(value: ProfileRouter.Destination.settings) { Image(systemName: "gearshape") }
                }
            }
        }
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
