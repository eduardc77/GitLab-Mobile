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

// Cached project details data transfer object to avoid circular dependencies
public struct CachedProjectDetailsDTO: Sendable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let namespaceName: String?
    public let description: String?
    public let starCount: Int
    public let forksCount: Int
    public let avatarUrl: URL?
    public let webUrl: URL
    public let createdAt: Date?
    public let lastActivityAt: Date?
    public let defaultBranch: String?
    public let visibility: String?
    public let topics: [String]
    public let cachedAt: Date

    public init(
        id: Int,
        name: String,
        pathWithNamespace: String,
        namespaceName: String?,
        description: String?,
        starCount: Int,
        forksCount: Int,
        avatarUrl: URL?,
        webUrl: URL,
        createdAt: Date?,
        lastActivityAt: Date?,
        defaultBranch: String?,
        visibility: String?,
        topics: [String],
        cachedAt: Date
    ) {
        self.id = id
        self.name = name
        self.pathWithNamespace = pathWithNamespace
        self.namespaceName = namespaceName
        self.description = description
        self.starCount = starCount
        self.forksCount = forksCount
        self.avatarUrl = avatarUrl
        self.webUrl = webUrl
        self.createdAt = createdAt
        self.lastActivityAt = lastActivityAt
        self.defaultBranch = defaultBranch
        self.visibility = visibility
        self.topics = topics
        self.cachedAt = cachedAt
    }
}

// Separate protocol for project details to avoid circular dependency
public protocol ProjectDetailsCacheProviding: Sendable {
    @MainActor func saveProjectDetails(_ details: ProjectDetails) throws
    @MainActor func loadProjectDetails(id: Int, staleInterval: TimeInterval) throws -> CachedProjectDetailsDTO?
    @MainActor func isProjectDetailsFresh(id: Int, staleInterval: TimeInterval) throws -> Bool
    @MainActor func clearProjectDetails(id: Int) throws
    @MainActor func clearAllProjectDetails() throws
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
