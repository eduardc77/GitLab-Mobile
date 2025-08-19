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

public struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State public var store: UserProjectsStore
    @State private var searchPresented = false

    public init(repository: any ProjectsRepository, scope: UserProjectsStore.Scope) {
        self._store = State(initialValue: UserProjectsStore(repository: repository, scope: scope))
    }

    public var body: some View {
        PaginatedList(
            items: store.items,
            isLoadingMore: store.isLoadingMore,
            onItemAppear: { project in
                if store.isNearEnd(for: project.id) {
                    Task(priority: .utility) { await store.loadMoreIfNeeded(currentItem: project) }
                }
            },
            row: { project in ProjectRow(project: project) }
        )
        .listStyle(.plain)
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await store.load() }
        .searchable(
            text: $store.query,
            isPresented: $searchPresented,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchSuggestions {
            if store.query.isEmpty && !(store.isLoading || store.isReloading || store.isSearching) {
                Section("Recent searches") {
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
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if store.items.isEmpty, !(store.isLoading || store.isReloading || store.isSearching) {
                ContentUnavailableView {
                    Label("No Projects", systemImage: "folder.badge.questionmark")
                } description: {
                    Text("No projects found. Try refreshing or check your connection.")
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { (store.errorMessage ?? "").isEmpty == false },
            set: { _ in store.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: { Text(store.errorMessage ?? "") }
        .task {
            await store.configureLocalCache { @MainActor in ProjectsCache(modelContext: modelContext) }
            await store.initialLoad()
        }
    }
}
