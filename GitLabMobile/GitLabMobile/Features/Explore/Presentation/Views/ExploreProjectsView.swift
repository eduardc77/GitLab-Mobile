//
//  ExploreProjectsView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ExploreProjectsView: View {
    @State public var store: ExploreProjectsStore
    @State private var searchPresented = false

    public init(service: ExploreProjectsService) {
        self._store = State(initialValue: ExploreProjectsStore(service: service))
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
        .navigationTitle("Explore Projects")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.initialLoad() }
        .searchable(
            text: $store.query,
            isPresented: $searchPresented,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .searchSuggestions {
            if store.query.isEmpty && !(store.isLoading || store.isReloading || store.isSearching) {
                Section("Recent Searches") {
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
        .alert("Error", isPresented: Binding(
            get: { (store.errorMessage ?? "").isEmpty == false },
            set: { _ in store.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: { Text(store.errorMessage ?? "") }
    }

    @ViewBuilder
    private var sortMenuContent: some View {
        Picker("Sort by", selection: $store.sortBy) {
            ForEach(ProjectsAPI.SortBy.allCases, id: \.self) { option in
                Text(option.displayTitle).tag(option)
            }
        }
        Picker("Direction", selection: $store.sortDirection) {
            ForEach(ProjectsAPI.SortDirection.allCases, id: \.self) { direction in
                Text(direction.displayTitle).tag(direction)
            }
        }
    }
}
