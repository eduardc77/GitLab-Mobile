//
//  ProjectsCacheProviding.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol ProjectsCacheProviding: Sendable {
    @MainActor func replacePage(key: ProjectsCacheKey, page: Int, items: [ProjectSummary], nextPage: Int?) throws
    @MainActor func loadPageWithFreshness(
        key: ProjectsCacheKey,
        page: Int,
        limit: Int,
        staleInterval: TimeInterval
    ) throws -> ProjectsCachePageResult?
}

public struct ProjectsCachePageResult: Sendable {
    public let items: [ProjectSummary]
    public let isFresh: Bool
    public let nextPage: Int?
    public init(items: [ProjectSummary], isFresh: Bool, nextPage: Int?) {
        self.items = items
        self.isFresh = isFresh
        self.nextPage = nextPage
    }
}

public struct ProjectsCacheKey: Hashable, Sendable {
    public let identifier: String
    public init(identifier: String) { self.identifier = identifier }
}
