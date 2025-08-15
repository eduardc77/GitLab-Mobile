//
//  ExploreProjectsStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Combine

@MainActor
@Observable
public final class ExploreProjectsStore {
    public enum Section: String, CaseIterable { case mostStarred, trending, active, inactive, all }
    private typealias Phase = LoadPhase

    public var errorMessage: String?
    public private(set) var items: [ProjectSummary] = []
    private var phase: Phase = .idle
    public var isLoading: Bool { phase == .initialLoading || phase == .loading || phase == .searching || phase == .reloading }
    public var isLoadingMore: Bool { phase == .loadingMore }
    public var isSearching: Bool { phase == .searching }
    public var isReloading: Bool { phase == .reloading }

    // Pagination: offset-based. Next page taken from X-Next-Page / Link headers
    @ObservationIgnored private var nextPageCursor: Int?
    // No keyset cursor in offset pagination
    @ObservationIgnored private let perPage = 20
    public private(set) var hasNextPage = true

    public private(set) var recentQueries: [String] = []

    private enum Constants {
        static let prefetchDistance: Int = StoreDefaults.prefetchDistance
        static let loadMoreThrottle: TimeInterval = StoreDefaults.loadMoreThrottle
    }
    @ObservationIgnored private let service: ExploreProjectsServiceProtocol
    @ObservationIgnored private let listMerger = ListMerger()
    @ObservationIgnored private var currentRequestID: Int = 0
    @ObservationIgnored private var lastLoadMoreAt: Date?
    private var currentFeedKey: String { "\(section.rawValue)|\(queryIfValid() ?? "")" }
    @ObservationIgnored private let querySubject = PassthroughSubject<String, Never>()
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var pendingSectionChange = false
    @ObservationIgnored private var currentLoadTask: Task<Void, Never>?

    public var section: Section = .mostStarred {
        didSet {
            guard oldValue != section else { return }
            // Skip auto-load on initial mount; initial load should be driven by the view's .task
            if items.isEmpty && phase == .idle { return }
            pendingSectionChange = true
            currentLoadTask?.cancel()
            phase = .reloading
            // Hard reset list and pagination to avoid any carry-over while switching feeds
            items.removeAll()
            nextPageCursor = nil
            hasNextPage = true
            currentLoadTask = startLoadTask(page: 1, perPage: perPage)
        }
    }

    public var query: String = "" {
        didSet {
            if oldValue != query {
                // Mark searching immediately so the overlay can show a spinner
                phase = .searching
                querySubject.send(query)
            }
        }
    }

    public init(service: ExploreProjectsServiceProtocol) {
        self.service = service
        setupDebouncedSearch()
        loadRecentQueries()
    }

    public func setSection(_ new: Section) async {
        section = new
        pendingSectionChange = true
        currentLoadTask?.cancel()
        phase = .reloading
        currentLoadTask = Task { [weak self] in await self?.performLoad(page: 1, perPage: self?.perPage ?? 20) }
        _ = await currentLoadTask?.value
    }

    public func load(page: Int = 1, perPage: Int = 20) async {
        _ = await startLoadTask(page: page, perPage: perPage).value
    }

    public func loadMoreIfNeeded(currentItem: ProjectSummary) async {
        // Only allow during steady state to avoid races on reload/search/initial load
        guard hasNextPage, phase == .idle, pendingSectionChange == false else { return }
        guard isNearEnd(for: currentItem.id) else { return }
        let nextPage = nextPageCursor
        guard nextPage != nil else { return }

        // Throttle bursty load-more triggers during fast flings
        let now = Date()
        if let last = lastLoadMoreAt, now.timeIntervalSince(last) < Constants.loadMoreThrottle { return }
        lastLoadMoreAt = now

        currentRequestID &+= 1
        let requestID = currentRequestID
        let expectedFeed = currentFeedKey

        phase = .loadingMore
        defer { if phase == .loadingMore { phase = .idle } }
        do {
            let result = try await fetch(page: nextPage ?? 1, perPage: perPage)
            guard requestID == currentRequestID, expectedFeed == currentFeedKey else { return }
            // Append unique by id to avoid transient overlaps from offset pagination on volatile sorts
            items = await listMerger.appendUniqueById(existing: items, newItems: result.items)
            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
        } catch {
            if requestID == currentRequestID {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Prefetching guard shared with UI
    public func isNearEnd(for projectId: Int) -> Bool {
        // Only consider prefetching when the list is in a steady idle state and we actually have a next page
        guard phase == .idle, pendingSectionChange == false, hasNextPage, nextPageCursor != nil else { return false }
        guard let index = items.firstIndex(where: { $0.id == projectId }) else { return false }
        let threshold = max(items.count - Constants.prefetchDistance, 0)
        return index >= threshold
    }

    public func updateQuery(_ newValue: String) {
        querySubject.send(newValue)
    }

    public func applySearch() async {
        currentLoadTask?.cancel()
        addRecentQueryIfNeeded()
        phase = .searching
        items.removeAll()
        nextPageCursor = nil
        hasNextPage = true
        _ = await startLoadTask(page: 1, perPage: perPage).value
    }

    private func queryIfValid() -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func performDebouncedSearch(_ text: String) async {
        if text != query { query = text }
        currentLoadTask?.cancel()
        addRecentQueryIfNeeded()
        phase = .searching
        items.removeAll()
        nextPageCursor = nil
        hasNextPage = true
        _ = await startLoadTask(page: 1, perPage: perPage).value
    }

    private func setupDebouncedSearch() {
        querySubject
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                Task { await self?.performDebouncedSearch(text) }
            }
            .store(in: &cancellables)
    }

    @discardableResult
    private func startLoadTask(page: Int, perPage: Int) -> Task<Void, Never> {
        currentLoadTask?.cancel()
        phase = (items.isEmpty && page == 1) ? .initialLoading : .loading
        let task: Task<Void, Never> = Task { [weak self] in
            guard let self else { return }
            await self.performLoad(page: page, perPage: perPage)
        }
        currentLoadTask = task
        return task
    }

    private func fetch(
        page: Int,
        perPage: Int
    ) async throws -> Paginated<[ProjectSummary]> {
        // Map section presets to endpoints
        let search = queryIfValid()
        switch section {
        case .mostStarred:
            return try await service.getMostStarred(page: page, perPage: perPage, search: search)
        case .trending:
            return try await service.getTrending(page: page, perPage: perPage, search: search)
        case .active:
            return try await service.getActive(page: page, perPage: perPage, search: search)
        case .inactive:
            return try await service.getInactive(page: page, perPage: perPage, search: search)
        case .all:
            // Default to recent activity desc for All
            return try await service.getList(
                orderBy: .lastActivityAt,
                page: page,
                perPage: perPage,
                search: search,
                publicOnly: true)
        }
    }

    private func performLoad(page: Int, perPage: Int) async {
        currentRequestID &+= 1
        let requestID = currentRequestID
        let isFirstPage = (page == 1)
        let expectedFeed = currentFeedKey
        errorMessage = nil
        do {
            if Task.isCancelled { return }
            if isFirstPage {
                nextPageCursor = nil
                hasNextPage = true
            }
            let result = try await fetch(page: page, perPage: perPage)
            if Task.isCancelled { return }
            guard requestID == currentRequestID, expectedFeed == currentFeedKey else { return }
            items = result.items

            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
            // winning request transitions handled below
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
            phase = .failed(error.localizedDescription)
        }
        // Only the winning (current) request should transition back to idle
        if requestID == currentRequestID && !Task.isCancelled {
            pendingSectionChange = false
            if phase != .loadingMore { phase = .idle }
        }
    }

    public func initialLoad() async {
        if items.isEmpty && phase == .idle {
            // Synchronously mark loading and clear items so the overlay shows immediately
            items.removeAll()
            nextPageCursor = nil
            hasNextPage = true
            phase = .initialLoading
            await load()
        }
    }

    // MARK: - Recent queries

    private func addRecentQueryIfNeeded() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let existingIdx = recentQueries.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            recentQueries.remove(at: existingIdx)
        }
        recentQueries.insert(trimmed, at: 0)
        if recentQueries.count > 10 { recentQueries.removeLast(recentQueries.count - 10) }
        saveRecentQueries()
    }

    private func loadRecentQueries() {
        if let saved = UserDefaults.standard.array(forKey: Self.recentQueriesKey) as? [String] {
            recentQueries = saved
        }
    }

    private func saveRecentQueries() {
        UserDefaults.standard.set(recentQueries, forKey: Self.recentQueriesKey)
    }

    private static let recentQueriesKey = "ExploreProjectsRecentQueries"
}
