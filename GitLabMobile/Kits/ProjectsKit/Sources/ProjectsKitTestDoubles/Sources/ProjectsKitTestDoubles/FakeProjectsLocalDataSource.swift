//
//  FakeProjectsLocalDataSource.swift
//  ProjectsKitTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import ProjectsData

public actor FakeProjectsLocalDataSource: ProjectsLocalDataSource {
    public var readResult: CachedPage<[ProjectSummary]> = CachedPage(value: nil, isFresh: false, nextPage: nil)
    public private(set) var writes: [String: [ProjectSummary]] = [:]

    public init() {}

    public func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async {}

    public func readPage(cacheKey: String, page: Int, limit: Int, staleInterval: TimeInterval) async -> CachedPage<[ProjectSummary]> {
        readResult
    }

    public func writePage(cacheKey: String, page: Int, items: [ProjectSummary], nextPage: Int?) async {
        writes[cacheKey] = items
    }

    // Helper to mutate from tests
    public func setReadResult(_ result: CachedPage<[ProjectSummary]>) {
        self.readResult = result
    }
}
