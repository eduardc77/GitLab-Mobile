//
//  ExploreProjectsStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import AsyncAlgorithms

@MainActor
@Observable
public final class ExploreProjectsStore {
    // MARK: - Types
    private enum LoadEvent: Equatable { case initial, refresh, sortChanged(SortContext), search(String) }
    private typealias Phase = LoadPhase
    private struct SortContext: Equatable, Hashable {
        let query: String?
        let sortBy: ProjectsAPI.SortBy
        let sort: ProjectsAPI.SortDirection
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

    // MARK: - Services & helpers
    @ObservationIgnored private let service: ExploreProjectsServiceProtocol
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

    public var sortBy: ProjectsAPI.SortBy = .starCount {
        didSet {
            guard oldValue != sortBy else { return }
            AppLog.explore.log("OrderBy change applied: \(String(describing: oldValue)) -> \(String(describing: self.sortBy))")
            pendingSectionChange = true
            phase = .reloading
            eventQueue.send(.sortChanged(sortContext))
        }
    }
    public var sortDirection: ProjectsAPI.SortDirection = .descending {
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

    public init(service: ExploreProjectsServiceProtocol) {
        self.service = service
        setupQueryStream()
        setupLoadEventsPipeline()
        Task { [weak self] in self?.recentQueries = await self?.recentStore.load() ?? [] }
    }
    
    public func load() async {
        AppLog.explore.debug("Reload requested")
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
            let result = try await fetch(page: nextPage ?? 1, perPage: perPage)
            guard expectedSortContext == sortContext else { return }
            // Deduplicate ids to avoid transient overlaps from offset pagination
            items = await listMerger.appendUniqueById(existing: items, newItems: result.items)
            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
            AppLog.explore.log("Load-more appended page=\(String(describing: nextPage))")
            let hasNextFlag = self.hasNextPage ? "1" : "0"
            AppLog.explore.log("totalItems=\(self.items.count) hasNext=\(hasNextFlag)")
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
        addRecentQueryIfNeeded()
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
        addRecentQueryIfNeeded()
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
                await self.fetchAndApplyFirstPage()
            case .refresh:
                self.phase = .reloading
                await self.fetchAndApplyFirstPage()
            case .sortChanged:
                self.phase = .reloading
                await self.fetchAndApplyFirstPage()
            case .search:
                self.phase = .searching
                await self.fetchAndApplyFirstPage()
            }
            self.pendingSectionChange = false
            if self.phase != .loadingMore { self.phase = .idle }
        }
    }

    private func fetchAndApplyFirstPage() async {
        do {
            let paginatedResult = try await fetch(page: 1, perPage: perPage)
            if Task.isCancelled { return }
            items = paginatedResult.items
            nextPageCursor = paginatedResult.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
            phase = .failed(errorMessage ?? "")
        }
    }

    public func restoreDefaultAfterSearchCancel() {
        if !query.isEmpty { query = "" }
        phase = .reloading
        eventQueue.send(.refresh)
    }

    private func fetch(
        page: Int,
        perPage: Int
    ) async throws -> Paginated<[ProjectSummary]> {
        AppLog.explore.debug("fn=fetch called page=\(page) perPage=\(perPage)")
        return try await service.getList(
            orderBy: sortBy,
            sort: sortDirection,
            page: page,
            perPage: perPage,
            search: queryIfValid())
    }

    public func initialLoad() async {
        AppLog.explore.debug("fn=initialLoad called")
        if items.isEmpty && (phase == .idle || phase == .initialLoading) {
            phase = .initialLoading
            eventQueue.send(.initial)
        }
    }

    // MARK: - Recent queries

    private func addRecentQueryIfNeeded() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            self.recentQueries = await recentStore.add(trimmed)
        }
    }

    private func loadRecentQueries() {
        Task { [weak self] in
            guard let self else { return }
            self.recentQueries = await recentStore.load()
        }
    }
}
