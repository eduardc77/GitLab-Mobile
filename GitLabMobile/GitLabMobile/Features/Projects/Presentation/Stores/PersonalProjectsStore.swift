//
//  PersonalProjectsStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Combine

@MainActor
@Observable
public final class PersonalProjectsStore {
    public enum Scope: Equatable { case owned, membership, starred, combined }
    private typealias Phase = LoadPhase

    public private(set) var items: [ProjectSummary] = []
    public var errorMessage: String?
    private var phase: Phase = .idle
    public var isLoading: Bool { phase == .initialLoading || phase == .loading || phase == .searching || phase == .reloading }
    public var isLoadingMore: Bool { phase == .loadingMore }
    public var isSearching: Bool { phase == .searching }

    public private(set) var hasNextPage = true
    public private(set) var recentQueries: [String] = []

    // Offset pagination (page number)
    @ObservationIgnored private var pageCursor: Int = 1
    @ObservationIgnored private let perPage: Int = 20
    public private(set) var scope: Scope
    @ObservationIgnored private let service: PersonalProjectsServiceProtocol
    @ObservationIgnored private let listMerger = ListMerger()
    @ObservationIgnored private let querySubject = PassthroughSubject<String, Never>()
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var currentRequestID: Int = 0
    @ObservationIgnored private var lastLoadMoreAt: Date?
    @ObservationIgnored private var currentLoadTask: Task<Void, Never>?
    private var currentFeedKey: String { "\(scope)|\(queryIfValid() ?? "")" }
    private enum Constants {
        static let prefetchDistance: Int = StoreDefaults.prefetchDistance
        static let loadMoreThrottle: TimeInterval = StoreDefaults.loadMoreThrottle
    }

    public var query: String = "" {
        didSet {
            if oldValue != query {
                querySubject.send(query)
            }
        }
    }

    public init(service: PersonalProjectsServiceProtocol, scope: Scope) {
        self.service = service
        self.scope = scope
        setupDebouncedSearch()
        loadRecentQueries()
    }

    public func setScope(_ newScope: Scope) async {
        guard newScope != scope else { return }
        scope = newScope
        currentLoadTask?.cancel()
        phase = .reloading
        _ = await startLoadTask(page: 1, perPage: perPage).value
    }

    public func load(page: Int = 1, perPage: Int = 20) async {
        _ = await startLoadTask(page: page, perPage: perPage).value
    }

    public func loadMoreIfNeeded(currentItem: ProjectSummary) async {
        guard hasNextPage, phase == .idle else { return }
        guard let index = items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = max(items.count - Constants.prefetchDistance, 0)
        guard index >= threshold else { return }
        // Throttle
        let now = Date()
        if let last = lastLoadMoreAt, now.timeIntervalSince(last) < 0.15 { return }
        lastLoadMoreAt = now

        currentRequestID &+= 1
        let requestID = currentRequestID
        let expectedFeed = currentFeedKey

        phase = .loadingMore
        defer { if phase == .loadingMore { phase = .idle } }
        do {
            let result = try await fetch(page: pageCursor + 1, perPage: perPage)
            guard requestID == currentRequestID, expectedFeed == currentFeedKey else { return }
            items = await listMerger.appendUniqueById(existing: items, newItems: result)
            if result.count == perPage {
                pageCursor += 1
                hasNextPage = true
            } else {
                hasNextPage = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search handling similar to Explore
    public func isNearEnd(for projectId: Int) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == projectId }) else { return false }
        let threshold = max(items.count - 3, 0)
        return index >= threshold
    }

    public func updateQuery(_ newValue: String) { querySubject.send(newValue) }

    public func applySearch() async {
        currentLoadTask?.cancel()
        addRecentQueryIfNeeded()
        phase = .searching
        items.removeAll()
        pageCursor = 1
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
        pageCursor = 1
        hasNextPage = true
        _ = await startLoadTask(page: 1, perPage: perPage).value
    }

    public func initialLoad() async {
        if items.isEmpty && phase == .idle {
            items.removeAll()
            pageCursor = 1
            hasNextPage = true
            phase = .initialLoading
            _ = await startLoadTask(page: 1, perPage: perPage).value
        }
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

    private static let recentQueriesKey = "PersonalProjectsRecentQueries"

    // MARK: - Internals
    private func fetch(page: Int, perPage: Int) async throws -> [ProjectSummary] {
        let search = queryIfValid()
        switch scope {
        case .owned:
            return try await service.owned(page: page, perPage: perPage, search: search)
        case .membership:
            return try await service.membership(page: page, perPage: perPage, search: search)
        case .starred:
            return try await service.starred(page: page, perPage: perPage, search: search)
        case .combined:
            async let ownedProjectsTask = service.owned(page: page, perPage: perPage, search: search)
            async let membershipProjectsTask = service.membership(page: page, perPage: perPage, search: search)
            let (owned, membership) = try await (ownedProjectsTask, membershipProjectsTask)
            let merged = await listMerger.appendUniqueById(existing: owned, newItems: membership)
            return merged.sorted { ($0.lastActivityAt ?? .distantPast) > ($1.lastActivityAt ?? .distantPast) }
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
                pageCursor = 1
                hasNextPage = true
            }
            let result = try await fetch(page: page, perPage: perPage)
            if Task.isCancelled { return }
            guard requestID == currentRequestID, expectedFeed == currentFeedKey else { return }
            items = result
            if result.count == perPage {
                pageCursor = isFirstPage ? 1 : pageCursor
                hasNextPage = true
            } else {
                hasNextPage = false
            }
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
            phase = .failed(error.localizedDescription)
        }
        if requestID == currentRequestID && !Task.isCancelled {
            if phase != .loadingMore { phase = .idle }
        }
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
}
