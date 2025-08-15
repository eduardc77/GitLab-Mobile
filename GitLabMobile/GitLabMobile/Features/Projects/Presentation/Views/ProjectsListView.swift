//
//  ProjectsListView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ProjectsListView: View {
    @State public var store: PersonalProjectsStore

    public init(service: PersonalProjectsService, scope: PersonalProjectsStore.Scope) {
        self._store = State(initialValue: PersonalProjectsStore(service: service, scope: scope))
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
            text: Binding(
                get: { store.query },
                set: { newValue in if newValue != store.query { store.updateQuery(newValue) } }
            ),
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchSuggestions {
            if store.query.isEmpty {
                Section("Recent searches") {
                    ForEach(store.recentQueries, id: \.self) { suggestion in
                        Text("**\(suggestion)**").searchCompletion(suggestion)
                    }
                }
            }
        }
        .onSubmit(of: .search) { Task(priority: .userInitiated) { await store.applySearch() } }
        .overlay {
            if store.isLoading && (store.items.isEmpty || store.isSearching) {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if store.items.isEmpty, !(store.isLoading || store.isSearching) {
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
        .task { await store.initialLoad() }
    }
}
