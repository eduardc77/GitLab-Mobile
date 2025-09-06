//
//  ProjectREADMEStore.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabLogging

private actor READMECache {
    private var storage = [String: ProjectREADME]()
    private var accessCounts = [String: Int]()

    func get(_ key: String) -> ProjectREADME? {
        if let value = storage[key] {
            accessCounts[key, default: 0] += 1
            return value
        }
        return nil
    }

    func set(_ value: ProjectREADME, forKey key: String) {
        storage[key] = value
        accessCounts[key] = 1
    }

    func remove(_ key: String) {
        storage.removeValue(forKey: key)
        accessCounts.removeValue(forKey: key)
    }

    func removeAll() {
        storage.removeAll()
        accessCounts.removeAll()
    }

    func statistics() -> (count: Int, totalAccesses: Int, averageAccesses: Double) {
        let count = storage.count
        let totalAccesses = accessCounts.values.reduce(0, +)
        let averageAccesses = !storage.isEmpty ? Double(totalAccesses) / Double(count) : 0
        return (count, totalAccesses, averageAccesses)
    }

    /// Clean up least recently used items if cache gets too large
    func cleanup(ifOver limit: Int = 50) {
        guard storage.count > limit else { return }

        // Simple LRU: remove items with lowest access counts
        let sortedKeys = accessCounts.sorted { $0.value < $1.value }.prefix(storage.count / 4)
        for (key, _) in sortedKeys {
            storage.removeValue(forKey: key)
            accessCounts.removeValue(forKey: key)
        }
    }
}

@MainActor
@Observable
public final class ProjectREADMEStore {
    enum State: Equatable {
        case idle
        case loading
        case loaded(ProjectREADME)
        case error(String)
    }

    // MARK: - Observable State
    var state: State = .idle

    // MARK: - UI State (Observable)
    var scrollToAnchor: String?
    @ObservationIgnored var hasLoadedInitially = false

    // MARK: - Secure Token Storage (not observable to prevent accidental exposure)
    @ObservationIgnored private var authToken: String?

    // MARK: - Controlled Token Access
    var secureAuthToken: String? {
        get { authToken }
        set { authToken = newValue }
    }

    // MARK: - Token Management
    func updateAuthToken(_ token: String?) {
        self.secureAuthToken = token
    }

    // MARK: - Private Implementation
    @ObservationIgnored private let repository: any ProjectsRepository
    @ObservationIgnored private let projectId: Int
    @ObservationIgnored private var loadTask: Task<Void, Never>?

    // MARK: - Caching
    private static let sharedCache = READMECache()
    private var cacheKey: String { "readme_\(projectId)" }

    public init(projectId: Int, repository: any ProjectsRepository, initialAnchor: String? = nil, authToken: String? = nil) {
        self.projectId = projectId
        self.repository = repository
        self.scrollToAnchor = initialAnchor
        self.secureAuthToken = authToken
    }

    // MARK: - State Management Helpers
    public func setScrollAnchor(_ anchor: String?) {
        // Only update if different to prevent unnecessary view updates
        if scrollToAnchor != anchor {
            scrollToAnchor = anchor
        }
    }

    public func markAsLoaded() {
        hasLoadedInitially = true
    }

    public func load() async {
        guard !hasLoadedInitially else { return }

        let key = cacheKey // Capture on main actor

        // Check cache first (async call to actor)
        if let cached = await Self.sharedCache.get(key) {
            AppLog.projects.debug("README loaded from cache for project \(self.projectId)")
            state = .loaded(cached)
            hasLoadedInitially = true
            return
        }

        // Cancel any existing load task
        loadTask?.cancel()

        hasLoadedInitially = true
        AppLog.projects.debug("ProjectREADMEStore load called for project \(self.projectId)")
        state = .loading

        loadTask = Task {
            defer { loadTask = nil }

            do {
                AppLog.projects.debug("Fetching README for project \(self.projectId)")
                let result = try await repository.projectREADME(projectId: projectId, ref: nil)
                AppLog.projects.log("README loaded successfully for project \(self.projectId)")

                // Cache the result (async call to actor)
                await Self.sharedCache.set(result, forKey: key)

                // Cleanup cache if it gets too large (async call to actor)
                await Self.sharedCache.cleanup()

                state = .loaded(result)
            } catch let error as READMEError {
                AppLog.projects.error("READMEError for project \(self.projectId): \(error)")
                let errorMsg: String
                switch error {
                case .notFound:
                    errorMsg = String(localized: "pd.error.readme_not_found")
                case .renderingFailed(let reason):
                    errorMsg = String(localized: "pd.error.readme_rendering") + ": \(reason)"
                case .networkError(let networkError):
                    // Network errors are already wrapped by READMEError, use generic handling
                    errorMsg = networkError.localizedDescription
                case .invalidContent:
                    errorMsg = String(localized: "pd.error.readme_invalid")
                }
                state = .error(errorMsg)
            } catch is CancellationError {
                // User cancelled - no error message needed
                AppLog.projects.debug("README loading cancelled for project \(self.projectId)")
            } catch {
                AppLog.projects.error("Unexpected error loading README for project \(self.projectId): \(error.localizedDescription)")
                state = .error((error as? LocalizedError)?.errorDescription ?? "Unable to load README file.")
            }
        }

        await loadTask?.value
    }

    // MARK: - Cache Management

    /// Clear cached README for this project
    public func clearCache() async {
        let key = cacheKey
        await Self.sharedCache.remove(key)
        AppLog.projects.debug("README cache cleared for project \(self.projectId)")
    }

    /// Clear all cached READMEs (useful for logout or memory management)
    public static func clearAllCache() async {
        await sharedCache.removeAll()
        AppLog.projects.debug("All README cache cleared")
    }

    /// Get cache statistics
    public static func cacheStatistics() async -> (count: Int, totalAccesses: Int, averageAccesses: Double) {
        await sharedCache.statistics()
    }

    deinit {
        loadTask?.cancel()
    }
}
