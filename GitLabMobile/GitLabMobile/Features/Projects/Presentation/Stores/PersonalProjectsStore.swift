//
//  PersonalProjectsStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import AsyncAlgorithms

@MainActor
@Observable
public final class PersonalProjectsStore {
    // MARK: - Types
    public enum Scope: Equatable { case owned, membership, starred, combined }
    private typealias Phase = LoadPhase
    private struct QueryContext: Equatable, Hashable { let scope: Scope; let query: String? }
    private enum LoadEvent: Equatable { case initial, refresh, contextChanged(QueryContext), search(String) }

    // MARK: - Public state
    public private(set) var items: [ProjectSummary] = []
    public var errorMessage: String?
    public private(set) var recentQueries: [String] = []
    public private(set) var hasNextPage = true
    public private(set) var scope: Scope

    // MARK: - Derived flags
    public var isLoading: Bool { phase == .initialLoading || phase == .loading || phase == .searching || phase == .reloading }
    public var isLoadingMore: Bool { phase == .loadingMore }
    public var isSearching: Bool { phase == .searching }
    public var isReloading: Bool { phase == .reloading }

    // MARK: - Services & helpers
    @ObservationIgnored private let service: PersonalProjectsServiceProtocol
    @ObservationIgnored private let listMerger = ListMerger()
    @ObservationIgnored private let loadMoreThrottler = PaginationThrottler()
    @ObservationIgnored private let queryStream = SearchQueryStream()
    @ObservationIgnored private let eventQueue = LatestWinsEventQueue<LoadEvent>()
    @ObservationIgnored private let recentStore = RecentQueriesStore(key: RecentQueriesStore.Keys.personalProjects)

    // MARK: - Pagination state
    @ObservationIgnored private var nextPageCursor: Int?
    @ObservationIgnored private let perPage: Int = StoreDefaults.perPage
    private var currentFeedID: QueryContext { QueryContext(scope: scope, query: queryIfValid()) }

    // MARK: - Internal state
    private var phase: Phase = .initialLoading {
        willSet {
            if newValue != self.phase {
                AppLog.projects.debug("phase \(String(describing: self.phase)) -> \(String(describing: newValue))")
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

    public init(service: PersonalProjectsServiceProtocol, scope: Scope) {
        self.service = service
        self.scope = scope
        setupQueryStream()
        setupLoadEventsPipeline()
        Task { [weak self] in self?.recentQueries = await self?.recentStore.load() ?? [] }
    }

    public func setScope(_ newScope: Scope) async {
        AppLog.projects.debug("fn=setScope called new=\(String(describing: newScope))")
        guard newScope != scope else { return }
        scope = newScope
        phase = .reloading
        AppLog.projects.log("Scope changed -> \(String(describing: newScope))")
        eventQueue.send(.contextChanged(currentFeedID))
    }

    public func load() async {
        AppLog.projects.debug("Reload requested")
        phase = .reloading
        eventQueue.send(.refresh)
    }

    public func loadMoreIfNeeded(currentItem: ProjectSummary) async {
        // Only prefetch during steady state to avoid races with reload/search/initial load
        guard hasNextPage, phase == .idle else { return }
        guard let index = items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = max(items.count - StoreDefaults.prefetchDistance, 0)
        guard index >= threshold else { return }
        // Throttle bursty load-more triggers during fast flings
        if loadMoreThrottler.shouldLoadMore() == false { return }

        let expectedFeed = currentFeedID
        let next = nextPageCursor
        AppLog.projects.debug("Load-more prefetch id=\(currentItem.id) next=\(String(describing: next))")
        guard let nextPage = next else { return }

        phase = .loadingMore
        defer { if phase == .loadingMore { phase = .idle } }
        do {
            let result = try await fetch(page: nextPage, perPage: perPage)
            guard expectedFeed == self.currentFeedID else { return }
            // Deduplicate ids to avoid transient overlaps from offset pagination
            items = await listMerger.appendUniqueById(existing: items, newItems: result.items)
            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
            AppLog.projects.log("Load-more appended page=\(nextPage)")
            AppLog.projects.log("totalItems=\(self.items.count) hasNext=\(self.hasNextPage ? "1" : "0")")
        } catch {
            errorMessage = error.localizedDescription
            AppLog.projects.error("Load-more failed: \(self.errorMessage ?? "-")")
        }
    }

    public func isNearEnd(for projectId: Int) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == projectId }) else { return false }
        let threshold = max(items.count - StoreDefaults.prefetchDistance, 0)
        return index >= threshold
    }

    public func applySearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            AppLog.projects.debug("applySearch ignored: empty query")
            return
        }
        AppLog.projects.debug("Search submitted (explicit) from applySearch")
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
        AppLog.projects.debug("Search triggered (debounced change)")
        AppLog.projects.log("Search query changed: \(text, privacy: .public)")
        addRecentQueryIfNeeded()
        phase = .searching
        eventQueue.send(.search(text))
    }

    public func initialLoad() async {
        AppLog.projects.debug("Initial load requested")
        if items.isEmpty && (phase == .idle || phase == .initialLoading) {
            phase = .initialLoading
            eventQueue.send(.initial)
        }
    }

    /// AsyncStream-based debounce pipeline setup
    private func setupQueryStream() {
        queryStream.start { [weak self] trimmed in
            await self?.performDebouncedSearch(trimmed)
        }
    }

    // MARK: - Internals
    private func fetch(page: Int, perPage: Int) async throws -> Paginated<[ProjectSummary]> {
        AppLog.projects.debug("Fetch called page=\(page) perPage=\(perPage)")
        let search = queryIfValid()
        switch scope {
        case .owned:
            return try await service.owned(page: page, perPage: perPage, search: search)
        case .membership:
            return try await service.membership(page: page, perPage: perPage, search: search)
        case .starred:
            return try await service.starred(page: page, perPage: perPage, search: search)
        case .combined:
            async let ownedTask = service.owned(page: page, perPage: perPage, search: search)
            async let memberTask = service.membership(page: page, perPage: perPage, search: search)
            let (owned, membership) = try await (ownedTask, memberTask)
            let merged = await listMerger.appendUniqueById(existing: owned.items, newItems: membership.items)
            let sorted = merged.sorted { ($0.lastActivityAt ?? .distantPast) > ($1.lastActivityAt ?? .distantPast) }
            let next = [owned.pageInfo?.nextPage, membership.pageInfo?.nextPage].compactMap { $0 }.min()
            let info = PageInfo(page: page, perPage: perPage, nextPage: next, prevPage: nil, total: nil, totalPages: nil)
            return Paginated(items: sorted, pageInfo: info)
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
            case .contextChanged:
                self.phase = .reloading
                await self.fetchAndApplyFirstPage()
            case .search:
                self.phase = .searching
                await self.fetchAndApplyFirstPage()
            }
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
