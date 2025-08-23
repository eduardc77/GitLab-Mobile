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
import GitLabNavigation

public struct HomeRootView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    private let router = HomeRouter()

    public init() {}

    public var body: some View {
        Group {
            switch authStore.status {
            case .authenticating:
                ProgressView(String(localized: .HomeLoadingL10n.loading))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            case .authenticated:
                yourWorkSection
            case .unauthenticated:
                SignInView()
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(String(localized: .HomeL10n.title))
        .alert(String(localized: .HomeAlertsL10n.error), isPresented: .constant(authStore.errorMessage != nil), actions: {
            Button(String(localized: .HomeAlertsL10n.okButtonTitle)) { authStore.clearError() }
        }, message: { Text(authStore.errorMessage ?? "") })
    }

    private var yourWorkSection: List<Never, some View> {
        return List {
            Section(String(localized: .HomeSectionsL10n.yourWork)) {
                ForEach(HomeEntry.allCases, id: \.self) { entry in
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
