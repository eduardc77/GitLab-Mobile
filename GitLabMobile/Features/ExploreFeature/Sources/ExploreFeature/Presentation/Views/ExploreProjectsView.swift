//
//  ExploreProjectsView.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import SwiftData
import ProjectsDomain
import GitLabDesignSystem
import ProjectsUI
import ProjectsCache
import GitLabLogging
import GitLabNavigation

public struct ExploreProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var store: ExploreProjectsStore
    @State private var searchPresented = false
    @Environment(ExploreRouter.self) private var router

    public init(repository: any ProjectsRepository) {
        self._store = State(initialValue: ExploreProjectsStore(repository: repository))
    }

    public var body: some View {
        PaginatedList(
            items: store.items,
            isLoadingMore: store.isLoadingMore,
            onItemAppear: { project in
                Task { @MainActor in
                    if store.isNearEnd(for: project.id) {
                        Task { await store.loadMoreIfNeeded(currentItem: project) }
                    }
                }
            },
            row: { project in
                Button {
                    router.navigate(to: .projectDetail(project))
                } label: {
                    ProjectRow(project: project)
                }
            }
        )
        .listStyle(.plain)
        .navigationTitle(String(localized: .ExploreProjectsL10n.title))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await store.configureLocalCache { @MainActor in ProjectsCache(modelContext: modelContext) }
            await store.initialLoad()
        }
        .searchable(
            text: $store.query,
            isPresented: $searchPresented,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchSuggestions {
            if store.query.isEmpty && !(store.isLoading || store.isReloading || store.isSearching) {
                Section(String(localized: .ExploreProjectsL10n.recentSearches)) {
                    ForEach(store.recentQueries, id: \.self) { suggestion in
                        Text(suggestion)
                            .lineLimit(1)
                            .fontWeight(.semibold)
                            .searchCompletion(suggestion)
                    }
                }
            }
        }
        .onChange(of: searchPresented) { oldValue, newValue in
            if oldValue && !newValue { store.restoreDefaultAfterSearchCancel() } // Cancel → reload section
        }
        .onSubmit(of: .search) {
            AppLog.explore.log("ExploreProjectsView.onSubmit fired")
            Task(priority: .userInitiated) { await store.applySearch() }
        }
        .refreshable { await store.load() }
        .overlay {
            if store.isReloading || store.isSearching || (store.isLoading && store.items.isEmpty) {
                LoadingView()
            } else if store.items.isEmpty, !(store.isLoading || store.isSearching) {
                ContentUnavailableView {
                    Label(String(localized: .ExploreProjectsL10n.emptyTitle), systemImage: "folder.badge.questionmark")
                } description: {
                    Text(.ExploreProjectsL10n.emptyDescription)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    if #available(iOS 18, *) {
                        sortMenuContent
                            .labelsVisibility(.visible)
                    } else {
                        sortMenuContent
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
        }
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .alert(String(localized: .ExploreAlertsL10n.errorTitle), isPresented: Binding(
            get: { (store.errorMessage ?? "").isEmpty == false },
            set: { _ in store.errorMessage = nil }
        )) {
            Button(String(localized: .ExploreAlertsL10n.okButtonTitle), role: .cancel) {}
        } message: { Text(store.errorMessage ?? "") }
    }

    @ViewBuilder
    private var sortMenuContent: some View {
        Picker(String(localized: .ExploreProjectsL10n.sortBy), selection: $store.sortBy) {
            ForEach(ProjectSortField.allCases, id: \.self) { option in
                Text(option.displayTitle).tag(option)
            }
        }
        Picker(String(localized: .ExploreProjectsL10n.direction), selection: $store.sortDirection) {
            ForEach(SortDirection.allCases, id: \.self) { direction in
                Text(direction.displayTitle).tag(direction)
            }
        }
    }
}
