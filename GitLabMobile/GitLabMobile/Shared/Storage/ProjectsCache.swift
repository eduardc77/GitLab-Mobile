//
//  ProjectsCache.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import SwiftData

@MainActor
public final class ProjectsCache {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public struct PageLoadResult: Sendable {
        public let items: [ProjectSummary]
        public let isFresh: Bool
        public let nextPage: Int?
    }

    // MARK: - Page helpers (composite key: key#p:<page>)
    private func compositeKey(_ key: ProjectsCacheKey, page: Int) -> String {
        "\(key.identifier)#p:\(page)"
    }

    public func replacePage(key: ProjectsCacheKey, page: Int, items: [ProjectSummary], nextPage: Int?) throws {
        // Delete existing page for composite key
        let pageKey = compositeKey(key, page: page)
        let pageFetch = FetchDescriptor<CachedProjectPage>(predicate: #Predicate { $0.key == pageKey })
        if let pages = try? modelContext.fetch(pageFetch) {
            for pageRow in pages { modelContext.delete(pageRow) }
        }
        // Upsert projects
        let existingFetch = FetchDescriptor<CachedProject>()
        let existing = (try? modelContext.fetch(existingFetch)) ?? []
        let existingIds = Set(existing.map { $0.id })
        for summary in items where existingIds.contains(summary.id) == false {
            modelContext.insert(CachedProject(from: summary))
        }
        // Save page mapping
        let ids = items.map { $0.id }
        let data = try JSONEncoder().encode(ids)
        let pageRow = CachedProjectPage(key: pageKey, cachedAt: Date(), projectIdsData: data, nextPage: nextPage)
        modelContext.insert(pageRow)
        try modelContext.save()
    }

    public func loadPageWithFreshness(
        key: ProjectsCacheKey,
        page: Int,
        limit: Int,
        staleInterval: TimeInterval
    ) throws -> PageLoadResult? {
        let pageKey = compositeKey(key, page: page)
        let fetch = FetchDescriptor<CachedProjectPage>(predicate: #Predicate { $0.key == pageKey })
        guard let pageRow = try modelContext.fetch(fetch).first else { return nil }
        let isFresh = Date().timeIntervalSince(pageRow.cachedAt) <= staleInterval
        guard let data = pageRow.projectIdsData else { return nil }
        let decodedIds = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        let ids = Array(decodedIds.prefix(limit))
        let projectsFetch = FetchDescriptor<CachedProject>()
        let rows = try modelContext.fetch(projectsFetch).filter { ids.contains($0.id) }
        let rowsById = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
        let items = ids.compactMap { rowsById[$0] }.map(ProjectSummary.init(from:))
        return PageLoadResult(items: items, isFresh: isFresh, nextPage: pageRow.nextPage)
    }

    public func loadPage(
        key: ProjectsCacheKey,
        page: Int,
        limit: Int
    ) throws -> [ProjectSummary]? {
        let pageKey = compositeKey(key, page: page)
        let fetch = FetchDescriptor<CachedProjectPage>(predicate: #Predicate { $0.key == pageKey })
        guard let pageRow = try modelContext.fetch(fetch).first else { return nil }
        guard let data = pageRow.projectIdsData else { return nil }
        let decodedIds = (try? JSONDecoder().decode([Int].self, from: data)) ?? []
        let ids = Array(decodedIds.prefix(limit))
        let projectsFetch = FetchDescriptor<CachedProject>()
        let rows = try modelContext.fetch(projectsFetch).filter { ids.contains($0.id) }
        let rowsById = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
        return ids.compactMap { rowsById[$0] }.map(ProjectSummary.init(from:))
    }

    // MARK: - Backward-compatible first-page APIs
    public func replaceFirstPage(key: ProjectsCacheKey, items: [ProjectSummary]) throws {
        try replacePage(key: key, page: 1, items: items, nextPage: nil)
    }

    public func loadFirstPage(key: ProjectsCacheKey, limit: Int, staleInterval: TimeInterval) throws -> [ProjectSummary]? {
        guard let result = try loadPageWithFreshness(
            key: key,
            page: 1,
            limit: limit,
            staleInterval: staleInterval
        ), result.isFresh else { return nil }
        return result.items
    }

    public func loadFirstPageWithFreshness(
        key: ProjectsCacheKey,
        limit: Int,
        staleInterval: TimeInterval
    ) throws -> PageLoadResult? {
        try loadPageWithFreshness(
            key: key,
            page: 1,
            limit: limit,
            staleInterval: staleInterval
        )
    }
}
