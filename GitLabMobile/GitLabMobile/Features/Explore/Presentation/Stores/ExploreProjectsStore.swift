import Foundation
import Observation
import Combine

@MainActor
@Observable
public final class ExploreProjectsStore {
    public enum Section: String, CaseIterable { case mostStarred, trending, active, inactive, all }

    public private(set) var section: Section = .mostStarred
    public private(set) var isLoading = false
    public private(set) var isLoadingMore = false
    public private(set) var errorMessage: String?
    public private(set) var items: [ProjectSummary] = []

    // Server-driven pagination cursor (page number from headers)
    @ObservationIgnored private var nextPageCursor: Int?
    @ObservationIgnored private let perPage = 20
    public private(set) var hasNextPage = true

    public var query: String = ""
    public private(set) var recentQueries: [String] = []

    public private(set) var isSearching = false
    public private(set) var isReloading = false

    @ObservationIgnored private let prefetchDistance = 3
    @ObservationIgnored private let service: ExploreProjectsServiceProtocol
    @ObservationIgnored private var currentRequestID: Int = 0
    @ObservationIgnored private let querySubject = CurrentValueSubject<String, Never>("")
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private var pendingSectionChange = false

    public init(service: ExploreProjectsServiceProtocol) {
        self.service = service
        setupDebouncedSearch()
        loadRecentQueries()
    }

    public func setSection(_ new: Section) {
        section = new
        pendingSectionChange = true
    }

    public func load(page: Int = 1, perPage: Int = 20) async {
        guard !isLoading else { return }

        currentRequestID &+= 1
        let requestID = currentRequestID

        let isFirstPage = (page == 1)
        let searchingNow = isFirstPage && (queryIfValid() != nil) && !pendingSectionChange
        let reloadingNow = isFirstPage && pendingSectionChange
        isLoading = true
        isSearching = searchingNow
        isReloading = reloadingNow
        defer {
            isLoading = false
            if searchingNow { isSearching = false }
            if reloadingNow { isReloading = false }
            pendingSectionChange = false
        }
        errorMessage = nil
        do {
            // Reset pagination cursor for new feeds
            if isFirstPage {
                nextPageCursor = nil
                hasNextPage = true
            }
            let result = try await fetch(page: page, perPage: perPage)
            guard requestID == currentRequestID else { return }
            items = result.items
            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
        } catch {
            if requestID == currentRequestID {
                errorMessage = error.localizedDescription
            }
        }

    }

    public func loadMoreIfNeeded(currentItem: ProjectSummary) async {
        guard hasNextPage, !isLoading, !isLoadingMore else { return }
        guard isNearEnd(for: currentItem.id) else { return }
        guard let next = nextPageCursor else { return }

        currentRequestID &+= 1
        let requestID = currentRequestID

        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let result = try await fetch(page: next, perPage: perPage)
            guard requestID == currentRequestID else { return }

            // Append only unseen ids to guard against server overlaps
            let existing = Set(items.map { $0.id })
            let toAppend = result.items.filter { !existing.contains($0.id) }
            items += toAppend
            nextPageCursor = result.pageInfo?.nextPage
            hasNextPage = (nextPageCursor != nil)
        } catch {
            if requestID == currentRequestID {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Prefetching guard shared with UI
    public func isNearEnd(for projectId: Int) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == projectId }) else { return false }
        let threshold = max(items.count - prefetchDistance, 0)
        return index >= threshold
    }

    public func updateQuery(_ newValue: String) {
        querySubject.send(newValue)
    }

    public func applySearch() async {
        addRecentQueryIfNeeded()
        await load(page: 1)
    }

    private func queryIfValid() -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func performDebouncedSearch(_ text: String) async {
        if text != query { query = text }
        addRecentQueryIfNeeded()
        await load(page: 1)
    }

    private func setupDebouncedSearch() {
        querySubject
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                Task { await self?.performDebouncedSearch(text) }
            }
            .store(in: &cancellables)
    }

    private func fetch(page: Int, perPage: Int) async throws -> Paginated<[ProjectSummary]> {
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
                publicOnly: true
            )
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
