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

    // MARK: - Dependencies & helpers
    @ObservationIgnored private let repository: any ProjectsRepository
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

    public init(repository: any ProjectsRepository, scope: Scope) {
        self.repository = repository
        self.scope = scope
        setupQueryStream()
        setupLoadEventsPipeline()
        Task { [weak self] in self?.recentQueries = await self?.recentStore.load() ?? [] }
    }

    public func configureLocalCache(_ makeCache: @escaping @Sendable @MainActor () -> ProjectsCache) async {
        await repository.configureLocalCache(makeCache: makeCache)
    }

    public func setScope(_ newScope: Scope) async {
        AppLog.projects.debug("fn=setScope called new=\(String(describing: newScope))")
        guard newScope != scope else { return }
        scope = newScope
        phase = .reloading
        AppLog.projects.log("Scope changed -> \(String(describing: newScope))")
        eventQueue.send(.contextChanged(currentFeedID))
    }

    public func load(file: StaticString = #fileID, function: StaticString = #function, line: UInt = #line) async {
        AppLog.projects.debug("Reload requested by \(file):\(line) \(function)")
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
            let stream = await repository.personalPage(
                scope: mapScope(scope),
                page: nextPage,
                perPage: perPage,
                search: queryIfValid()
            )
            for try await event in stream {
                guard expectedFeed == self.currentFeedID else { break }
                items = await listMerger.appendUniqueById(existing: items, newItems: event.value.items)
                nextPageCursor = event.value.nextPage
                hasNextPage = (nextPageCursor != nil)
                AppLog.projects.log("Load-more applied page=\(nextPage) stale=\(event.isStale ? "1" : "0")")
            }
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

    public func initialLoad(file: StaticString = #fileID, function: StaticString = #function, line: UInt = #line) async {
        AppLog.projects.debug("Initial load requested by \(file):\(line) \(function)")
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
    // No direct fetch; repository streams are consumed in place

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
            let stream = await repository.personalPage(
                scope: mapScope(scope),
                page: 1,
                perPage: perPage,
                search: queryIfValid()
            )
            for try await event in stream {
                items = event.value.items
                nextPageCursor = event.value.nextPage
                hasNextPage = (nextPageCursor != nil)
                if event.isStale {
                    AppLog.projects.log("Applied cached first page")
                } else {
                    AppLog.projects.log("Applied fresh first page")
                }
            }
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
            phase = .failed(errorMessage ?? "")
        }
    }

    private func mapScope(_ scope: Scope) -> PersonalProjectsScope {
        switch scope {
        case .owned: return .owned
        case .membership: return .membership
        case .starred: return .starred
        case .combined: return .combined
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
