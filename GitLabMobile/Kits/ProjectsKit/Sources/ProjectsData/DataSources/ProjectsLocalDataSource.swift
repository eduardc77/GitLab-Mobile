//
//  ProjectsLocalDataSource.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain

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
	func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async
	func readPage(cacheKey: String, page: Int, limit: Int, staleInterval: TimeInterval) async -> CachedPage<[ProjectSummary]>
	func writePage(cacheKey: String, page: Int, items: [ProjectSummary], nextPage: Int?) async
}

// Separate protocol for project details
public protocol ProjectDetailsLocalDataSource: Sendable {
	func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectDetailsCacheProviding) async
	func saveProjectDetails(_ details: ProjectDetails) async
	func loadProjectDetails(id: Int, staleInterval: TimeInterval) async -> CachedProjectDetailsDTO?
	func isProjectDetailsFresh(id: Int, staleInterval: TimeInterval) async -> Bool
	func clearProjectDetails(id: Int) async
	func clearAllProjectDetails() async
}

public actor DefaultProjectsLocalDataSource: ProjectsLocalDataSource {
	private var cache: ProjectsCacheProviding?

	public init() {}

	public func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async {
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

	// MARK: - Project Details Caching

	public func saveProjectDetails(_ details: ProjectDetails) async {
		// Project details caching is handled by DefaultProjectDetailsLocalDataSource
		// This method is here for protocol compliance but not used for projects list
	}

	public func loadProjectDetails(id: Int, staleInterval: TimeInterval) async -> CachedProjectDetailsDTO? {
		// Project details caching is handled by DefaultProjectDetailsLocalDataSource
		// This method is here for protocol compliance but not used for projects list
		return nil
	}

	public func isProjectDetailsFresh(id: Int, staleInterval: TimeInterval) async -> Bool {
		// Project details caching is handled by DefaultProjectDetailsLocalDataSource
		// This method is here for protocol compliance but not used for projects list
		return false
	}

	public func clearProjectDetails(id: Int) async {
		// Project details caching is handled by DefaultProjectDetailsLocalDataSource
		// This method is here for protocol compliance but not used for projects list
	}

	public func clearAllProjectDetails() async {
		// Project details caching is handled by DefaultProjectDetailsLocalDataSource
		// This method is here for protocol compliance but not used for projects list
	}
}

// MARK: - Project Details Local Data Source

public actor DefaultProjectDetailsLocalDataSource: ProjectDetailsLocalDataSource {
	private var cache: ProjectDetailsCacheProviding?

	public init() {}

	public func configure(makeCache: @escaping @Sendable @MainActor () -> ProjectDetailsCacheProviding) async {
		let instance = await makeCache()
		self.cache = instance
	}

	public func saveProjectDetails(_ details: ProjectDetails) async {
		guard let cache else { return }
		await MainActor.run {
			try? cache.saveProjectDetails(details)
		}
	}

	public func loadProjectDetails(id: Int, staleInterval: TimeInterval) async -> CachedProjectDetailsDTO? {
		guard let cache else { return nil }
		return await MainActor.run {
			try? cache.loadProjectDetails(id: id, staleInterval: staleInterval)
		}
	}

	public func isProjectDetailsFresh(id: Int, staleInterval: TimeInterval) async -> Bool {
		guard let cache else { return false }
		return (await MainActor.run {
			try? cache.isProjectDetailsFresh(id: id, staleInterval: staleInterval)
		}) ?? false
	}

	public func clearProjectDetails(id: Int) async {
		guard let cache else { return }
		await MainActor.run {
            try? cache.clearProjectDetails(id: id)
		}
	}

	public func clearAllProjectDetails() async {
		guard let cache else { return }
		await MainActor.run {
			try? cache.clearAllProjectDetails()
		}
	}
}
