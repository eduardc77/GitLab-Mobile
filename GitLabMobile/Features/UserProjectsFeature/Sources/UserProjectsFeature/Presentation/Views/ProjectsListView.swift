//
//  ProjectsListView.swift
//  UserProjectsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import SwiftData
import ProjectsDomain
import GitLabDesignSystem
import ProjectsUI
import GitLabLogging
import ProjectsCache
import GitLabNavigation

public struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: UserProjectsStore
    @State private var searchPresented = false
    private let navigationContext: NavigationContext

    public enum NavigationContext {
        case home(HomeRouter)
        case profile(ProfileRouter)
    }

    public init(
        repository: any ProjectsRepository,
        scope: UserProjectsStore.Scope,
        navigationContext: NavigationContext
    ) {
        self._store = State(initialValue: UserProjectsStore(repository: repository, scope: scope))
        self.navigationContext = navigationContext
    }

    public var body: some View {
        PaginatedList(
            items: store.items,
            isLoadingMore: store.isLoadingMore,
            onItemAppear: { project in
                Task(priority: .utility) { @MainActor in
                    if store.isNearEnd(for: project.id) {
                        await store.loadMoreIfNeeded(currentItem: project)
                    }
                }
            },
            row: { project in
                switch navigationContext {
                case .home(let router):
                    Button { router.navigate(to: .projectDetail(project)) } label: { ProjectRow(project: project) }
                case .profile(let router):
                    Button { router.navigate(to: .projectDetail(project)) } label: { ProjectRow(project: project) }
                }
            }
        )
        .listStyle(.plain)
        .navigationTitle(String(localized: .UserProjectsL10n.title))
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await store.load() }
        .searchable(
            text: $store.query,
            isPresented: $searchPresented,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchSuggestions {
            if store.query.isEmpty && !(store.isLoading || store.isReloading || store.isSearching) {
                Section(String(localized: .UserProjectsL10n.recentSearches)) {
                    ForEach(store.recentQueries, id: \.self) { suggestion in
                        Text("**\\(suggestion)**").searchCompletion(suggestion)
                    }
                }
            }
        }
        .onChange(of: searchPresented) { oldValue, newValue in
            if oldValue && !newValue { store.restoreDefaultAfterSearchCancel() }
        }
        .onSubmit(of: .search) {
            AppLog.projects.log("ProjectsListView.onSubmit fired")
            Task(priority: .userInitiated) { await store.applySearch() }
        }
        .overlay {
            if store.isReloading || store.isSearching || (store.isLoading && store.items.isEmpty) {
                LoadingView()
            } else if store.items.isEmpty, !(store.isLoading || store.isReloading || store.isSearching) {
                ContentUnavailableView {
                    Label(String(localized: .UserProjectsL10n.emptyTitle), systemImage: "folder.badge.questionmark")
                } description: {
                    Text(.UserProjectsL10n.emptyDescription)
                }
            }
        }
        .alert(String(localized: .UserProjectsL10n.errorTitle), isPresented: Binding(
            get: { (store.errorMessage ?? "").isEmpty == false },
            set: { _ in store.errorMessage = nil }
        )) {
            Button(String(localized: .UserProjectsL10n.okButtonTitle), role: .cancel) {}
        } message: { Text(store.errorMessage ?? "") }
        .task {
            await store.configureLocalCache { @MainActor in ProjectsCache(modelContext: modelContext) }
            await store.initialLoad()
        }
    }
}
