//
//  ExploreProjectsStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

@MainActor
@Observable
public final class ExploreProjectsStore {
    // MARK: - Types
    private enum LoadEvent: Equatable { case initial, refresh, sortChanged(SortContext), search(String) }
    private typealias Phase = LoadPhase
    private struct SortContext: Equatable, Hashable {
        let query: String?
        let sortBy: ProjectsEndpoints.SortBy
        let sort: ProjectsEndpoints.SortDirection
    }

    // MARK: - Public state
    public var errorMessage: String?
    public private(set) var items: [ProjectSummary] = []
    public private(set) var recentQueries: [String] = []
    public private(set) var hasNextPage = true

    // MARK: - Derived flags
    public var isLoading: Bool { phase == .initialLoading || phase == .loading || phase == .searching || phase == .reloading }
    public var isLoadingMore: Bool { phase == .loadingMore }
    public var isSearching: Bool { phase == .searching }
    public var isReloading: Bool { phase == .reloading }

    // MARK: - Dependencies & helpers
    @ObservationIgnored private let repository: any ProjectsRepository
    @ObservationIgnored private let listMerger = ListMerger()
    @ObservationIgnored private let loadMoreThrottler = PaginationThrottler()
    @ObservationIgnored private let recentStore = RecentQueriesStore(key: RecentQueriesStore.Keys.exploreProjects)
    @ObservationIgnored private let queryStream = SearchQueryStream()
    @ObservationIgnored private let eventQueue = LatestWinsEventQueue<LoadEvent>()

    // MARK: - Pagination state
    @ObservationIgnored private var nextPageCursor: Int?
    @ObservationIgnored private let perPage = StoreDefaults.perPage
    private var sortContext: SortContext { SortContext(query: queryIfValid(), sortBy: sortBy, sort: sortDirection) }
    @ObservationIgnored private var pendingSectionChange = false

    public var sortBy: ProjectsEndpoints.SortBy = .starCount {
        didSet {
            guard oldValue != sortBy else { return }
            AppLog.explore.log("OrderBy change applied: \(String(describing: oldValue)) -> \(String(describing: self.sortBy))")
            pendingSectionChange = true
            phase = .reloading
            eventQueue.send(.sortChanged(sortContext))
        }
    }
    public var sortDirection: ProjectsEndpoints.SortDirection = .descending {
        didSet {
            guard oldValue != sortDirection else { return }
            AppLog.explore.log("Sort direction change applied: \(String(describing: oldValue)) -> \(String(describing: self.sortDirection))")
            pendingSectionChange = true
            phase = .reloading
            eventQueue.send(.sortChanged(sortContext))
        }
    }

    // MARK: - Internal state
    private var phase: Phase = .initialLoading {
        willSet {
            if newValue != self.phase {
                AppLog.explore.debug("phase \(String(describing: self.phase)) -> \(String(describing: newValue))")
            }
        }
    }

    // MARK: - Search
    public var query: String = "" {
        didSet {
            if oldValue != query {
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { phase = .searching }
                queryStream.yield(query)
            }
        }
    }

    public init(repository: any ProjectsRepository) {
        self.repository = repository
        setupQueryStream()
        setupLoadEventsPipeline()
        Task { [weak self] in await self?.loadRecentQueries() }
    }

    public func configureLocalCache(_ makeCache: @escaping @Sendable @MainActor () -> ProjectsCache) async {
        await repository.configureLocalCache(makeCache: makeCache)
    }
    
    public func load(file: StaticString = #fileID, function: StaticString = #function, line: UInt = #line) async {
        AppLog.explore.debug("Reload requested by \(file):\(line) \(function)")
        phase = .reloading
        eventQueue.send(.refresh)
    }

    public func loadMoreIfNeeded(currentItem: ProjectSummary) async {
        // Only prefetch during steady state to avoid races with reload/search/initial load
        guard hasNextPage, phase == .idle, pendingSectionChange == false else { return }
        guard isNearEnd(for: currentItem.id) else { return }
        let nextPage = nextPageCursor
        guard nextPage != nil else { return }
        AppLog.explore.debug("Load-more prefetch id=\(currentItem.id) next=\(String(describing: nextPage))")

        // Throttle bursty load-more triggers during fast flings
        if loadMoreThrottler.shouldLoadMore() == false { return }

        phase = .loadingMore
        defer { if phase == .loadingMore { phase = .idle } }
        do {
            let expectedSortContext = sortContext
            let pageToLoad = nextPage ?? 1
            let stream = await repository.explorePage(
                orderBy: sortBy,
                sort: sortDirection,
                page: pageToLoad,
                perPage: perPage,
                search: queryIfValid()
            )
            for try await event in stream {
                guard expectedSortContext == sortContext else { break }
                items = await listMerger.appendUniqueById(existing: items, newItems: event.value.items)
                nextPageCursor = event.value.nextPage
                hasNextPage = (nextPageCursor != nil)
                AppLog.explore.log("Load-more applied page=\(pageToLoad) stale=\(event.isStale ? "1" : "0")")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func isNearEnd(for projectId: Int) -> Bool {
        // Only consider prefetching when the list is in a steady idle state and we actually have a next page
        guard phase == .idle, pendingSectionChange == false, hasNextPage, nextPageCursor != nil else { return false }
        guard let index = items.firstIndex(where: { $0.id == projectId }) else { return false }
        let threshold = max(items.count - StoreDefaults.prefetchDistance, 0)
        return index >= threshold
    }

    public func applySearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            AppLog.explore.debug("applySearch ignored: empty query")
            return
        }
        AppLog.explore.debug("Search submitted (explicit) from applySearch")
        await addRecentQueryIfNeeded()
        phase = .searching
        eventQueue.send(.search(trimmed))
    }

    private func queryIfValid() -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func performDebouncedSearch(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if phase == .searching { phase = .idle }
            return
        }
        AppLog.explore.debug("Search triggered (debounced change)")
        AppLog.explore.log("Search query changed: \(text, privacy: .public)")
        await addRecentQueryIfNeeded()
        phase = .searching
        eventQueue.send(.search(text))
    }

    private func setupQueryStream() {
        queryStream.start { [weak self] trimmed in
            await self?.performDebouncedSearch(trimmed)
        }
    }
    
    private func setupLoadEventsPipeline() {
        eventQueue.start { [weak self] event in
            guard let self else { return }
            self.errorMessage = nil
            switch event {
            case .initial:
                self.phase = .initialLoading
                AppLog.explore.debug("FetchFirstPage trigger: event=initial key=\(self.debugKey())")
                await self.fetchAndApplyFirstPage()
            case .refresh:
                self.phase = .reloading
                AppLog.explore.debug("FetchFirstPage trigger: event=refresh key=\(self.debugKey())")
                await self.fetchAndApplyFirstPage()
            case .sortChanged:
                self.phase = .reloading
                AppLog.explore.debug("FetchFirstPage trigger: event=sortChanged key=\(self.debugKey())")
                await self.fetchAndApplyFirstPage()
            case .search:
                self.phase = .searching
                AppLog.explore.debug("FetchFirstPage trigger: event=search key=\(self.debugKey())")
                await self.fetchAndApplyFirstPage()
            }
            self.pendingSectionChange = false
            if self.phase != .loadingMore { self.phase = .idle }
        }
    }

    private func fetchAndApplyFirstPage() async {
        do {
            let expectedSortContext = sortContext
            let rid = String(UUID().uuidString.prefix(8))
            let stream = await repository.explorePage(
                orderBy: sortBy,
                sort: sortDirection,
                page: 1,
                perPage: perPage,
                search: queryIfValid()
            )
            for try await event in stream {
                guard expectedSortContext == sortContext else { break }
                items = event.value.items
                nextPageCursor = event.value.nextPage
                hasNextPage = (nextPageCursor != nil)
                let freshness = event.isStale ? "cached" : "fresh"
                AppLog.explore.log("[rid=\(rid)] Applied \(freshness) first page key=\(self.debugKey()) next=\(String(describing: self.nextPageCursor))")
            }
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
            phase = .failed(errorMessage ?? "")
        }
    }

    private func debugKey() -> String {
        let queryPart = sortContext.query?.lowercased() ?? "__none__"
        return "explore:\(sortContext.sortBy.rawValue):\(sortContext.sort.rawValue):\(queryPart)"
    }

    public func restoreDefaultAfterSearchCancel() {
        if !query.isEmpty { query = "" }
        phase = .reloading
        eventQueue.send(.refresh)
    }

    public func initialLoad() async {
        if items.isEmpty && (phase == .idle || phase == .initialLoading) {
            phase = .initialLoading
            eventQueue.send(.initial)
        }
    }

    // MARK: - Recent queries

    private func addRecentQueryIfNeeded() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let updated = await recentStore.add(trimmed)
        if updated != recentQueries { recentQueries = updated }
    }

    private func loadRecentQueries() async {
        let loaded = await recentStore.load()
        if loaded != recentQueries { recentQueries = loaded }
    }
}
