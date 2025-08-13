import SwiftUI

public struct ExploreProjectsView: View {
    @State var store: ExploreProjectsStore

    public var body: some View {
        List {
            Section {
                ForEach(store.items) { project in
                    ProjectRow(project: project)
                        .onAppear {
                            if store.isNearEnd(for: project.id) {
                                Task {
                                    await store.loadMoreIfNeeded(currentItem: project)
                                }
                            }
                        }
                }

                if store.isLoadingMore {
                    HStack(spacing: 8) {
                        ProgressView().scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                }
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .navigationTitle("Explore projects")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: Binding(
                get: { store.query },
                set: { newValue in
                    if newValue != store.query { store.updateQuery(newValue) }
                }
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
        .onSubmit(of: .search) {
            Task { await store.applySearch() }
        }
        .task(id: store.section) { await store.load() }
        .refreshable { await store.load() }
        .overlay {
            if store.isLoading && (store.items.isEmpty || store.isReloading || store.isSearching) {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if store.items.isEmpty, !store.isLoading {
                ContentUnavailableView {
                    Label("No Projects", systemImage: "folder.badge.questionmark")
                } description: {
                    Text("No projects found. Try refreshing or check your connection.")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort by", selection: Binding(
                        get: { store.section },
                        set: { store.setSection($0) }
                    )) {
                        Text("Most starred").tag(ExploreProjectsStore.Section.mostStarred)
                        Text("Trending").tag(ExploreProjectsStore.Section.trending)
                        Text("Active").tag(ExploreProjectsStore.Section.active)
                        Text("Inactive").tag(ExploreProjectsStore.Section.inactive)
                        Text("All").tag(ExploreProjectsStore.Section.all)
                    }
                } label: { Label("Sort", systemImage: "line.3.horizontal.decrease.circle") }
            }
        }
        .alert("Error", isPresented: .constant(!(store.errorMessage ?? "").isEmpty)) {
            Button("OK", role: .cancel) {}
        } message: { Text(store.errorMessage ?? "") }
    }
}
