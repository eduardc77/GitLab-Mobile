//
//  ProjectsLocalDataSource.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct CachedPage<T: Sendable>: Sendable {
	public let value: T?
	public let isFresh: Bool
	public let nextPage: Int?
	public init(value: T?, isFresh: Bool, nextPage: Int?) {
		self.value = value
		self.isFresh = isFresh
		self.nextPage = nextPage
	}
}

public protocol ProjectsLocalDataSource: Sendable {
	func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectsCache) async
	func readPage(cacheKey: String, page: Int, limit: Int, staleInterval: TimeInterval) async -> CachedPage<[ProjectSummary]>
	func writePage(cacheKey: String, page: Int, items: [ProjectSummary], nextPage: Int?) async
}

public actor DefaultProjectsLocalDataSource: ProjectsLocalDataSource {
	private var cache: ProjectsCache?

	public init() {}

	public func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectsCache) async {
		let instance = await makeCache()
		self.cache = instance
	}

	public func readPage(cacheKey: String, page: Int, limit: Int, staleInterval: TimeInterval) async -> CachedPage<[ProjectSummary]> {
		guard let cache else { return CachedPage(value: nil, isFresh: false, nextPage: nil) }
		let key = ProjectsCacheKey(identifier: cacheKey)
		do {
			return try await MainActor.run {
				if let result = try cache.loadPageWithFreshness(
					key: key,
					page: page,
					limit: limit,
					staleInterval: staleInterval
				) {
					return CachedPage(value: result.items, isFresh: result.isFresh, nextPage: result.nextPage)
				}
				return CachedPage(value: nil, isFresh: false, nextPage: nil)
			}
		} catch {
			return CachedPage(value: nil, isFresh: false, nextPage: nil)
		}
	}

	public func writePage(cacheKey: String, page: Int, items: [ProjectSummary], nextPage: Int?) async {
		guard let cache else { return }
		let key = ProjectsCacheKey(identifier: cacheKey)
		await MainActor.run {
			try? cache.replacePage(key: key, page: page, items: items, nextPage: nextPage)
		}
	}
}
