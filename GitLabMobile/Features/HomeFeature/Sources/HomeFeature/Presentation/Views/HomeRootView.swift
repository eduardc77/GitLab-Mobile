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
            .navigationDestination(for: HomeCoordinator.Destination.self) { destination in
                switch destination {
                case .projects:
                    ProjectsListView(repository: projectsDependencies.repository, scope: .combined)
                case .groups:
                    Text(.HomeDestinationsL10n.groups)
                case .issues:
                    Text(.HomeDestinationsL10n.issues)
                case .mergeRequests:
                    Text(.HomeDestinationsL10n.mergeRequests)
                case .todo:
                    Text(.HomeDestinationsL10n.todo)
                case .milestones:
                    Text(.HomeDestinationsL10n.milestones)
                case .snippets:
                    Text(.HomeDestinationsL10n.snippets)
                case .activity:
                    Text(.HomeDestinationsL10n.activity)
                }
            }
            .alert(String(localized: .HomeAlertsL10n.error), isPresented: .constant(authStore.errorMessage != nil), actions: {
                Button(String(localized: .HomeAlertsL10n.okButtonTitle)) { authStore.clearError() }
            }, message: { Text(authStore.errorMessage ?? "") })
        }
    }

    private var yourWorkSection: List<Never, some View> {
        return List {
            Section(String(localized: .HomeSectionsL10n.yourWork)) {
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
