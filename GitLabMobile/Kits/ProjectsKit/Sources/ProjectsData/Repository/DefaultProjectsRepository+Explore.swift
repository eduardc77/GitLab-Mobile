//
//  DefaultProjectsRepository+Explore.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabUtilities
import ProjectsCache
import GitLabNetwork
import GitLabLogging

// MARK: - Explore Projects
extension DefaultProjectsRepository {

    public func explorePage(
        orderBy: ProjectSortField,
        sort: SortDirection,
        page: Int,
        perPage: Int,
        search: String?
    ) async -> AsyncThrowingStream<RepositoryResult<RepositoryPage<[ProjectSummary]>>, Error> {
        let cacheKey = makeExploreCacheKey(orderBy: orderBy, sort: sort, search: search)
        let local = self.local
        let remote = self.remote
        let staleness = self.staleness
        return AsyncThrowingStream { continuation in
            Task {
                let cached = await local.readPage(cacheKey: cacheKey, page: page, limit: perPage, staleInterval: staleness)
                if let value = cached.value, value.isEmpty == false {
                    continuation.yield(
                        RepositoryResult(
                            value: RepositoryPage(items: value, nextPage: cached.nextPage),
                            isStale: !cached.isFresh
                        )
                    )
                    // If cache is fresh, skip network revalidation except for page 1 (SWR for first page)
                    if cached.isFresh && page != 1 {
                        continuation.finish()
                        return
                    }
                }
                do {
                    let pagedDTOs = try await remote.fetchExplore(
                        orderBy: orderBy.endpointSortBy,
                        sort: sort.endpointSortDirection,
                        page: page,
                        perPage: perPage,
                        search: search
                    )
                    let models = pagedDTOs.items.map { $0.toDomain() }
                    await local.writePage(
                        cacheKey: cacheKey,
                        page: page,
                        items: models,
                        nextPage: pagedDTOs.pageInfo?.nextPage
                    )
                    continuation.yield(
                        RepositoryResult(
                            value: RepositoryPage(items: models, nextPage: pagedDTOs.pageInfo?.nextPage),
                            isStale: false
                        )
                    )
                    continuation.finish()
                } catch {
                    if cached.value != nil {
                        continuation.finish()
                    } else {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }

    private func makeExploreCacheKey(
        orderBy: ProjectSortField,
        sort: SortDirection,
        search: String?
    ) -> String {
        let trimmed = search?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed?.lowercased()
        let queryPart = (lowered?.isEmpty == false) ? (lowered ?? "__none__") : "__none__"
        return "explore:\(orderBy.rawValue):\(sort.rawValue):\(queryPart)"
    }
}
