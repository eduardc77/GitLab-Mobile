//
//  ProjectDetails.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// Detailed read-only information for a GitLab project.
/// Starts minimal and can be extended as we surface more fields from the API.
public struct ProjectDetails: Identifiable, Equatable, Sendable {
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
        topics: [String]
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
    }
}

// MARK: - Cached Model

import SwiftData

@Model
final public class CachedProjectDetails {
    @Attribute(.unique) public var id: Int
    public var name: String
    public var pathWithNamespace: String
    public var namespaceName: String?
    public var projectDescription: String?
    public var starCount: Int
    public var forksCount: Int
    public var avatarUrlString: String?
    public var webUrlString: String
    public var createdAt: Date?
    public var lastActivityAt: Date?
    public var defaultBranch: String?
    public var visibility: String?
    public var topicsData: Data?
    public var cachedAt: Date

    public init(
        id: Int,
        name: String,
        pathWithNamespace: String,
        namespaceName: String?,
        projectDescription: String?,
        starCount: Int,
        forksCount: Int,
        avatarUrlString: String?,
        webUrlString: String,
        createdAt: Date?,
        lastActivityAt: Date?,
        defaultBranch: String?,
        visibility: String?,
        topicsData: Data?,
        cachedAt: Date
    ) {
        self.id = id
        self.name = name
        self.pathWithNamespace = pathWithNamespace
        self.namespaceName = namespaceName
        self.projectDescription = projectDescription
        self.starCount = starCount
        self.forksCount = forksCount
        self.avatarUrlString = avatarUrlString
        self.webUrlString = webUrlString
        self.createdAt = createdAt
        self.lastActivityAt = lastActivityAt
        self.defaultBranch = defaultBranch
        self.visibility = visibility
        self.topicsData = topicsData
        self.cachedAt = cachedAt
    }

    public convenience init(from details: ProjectDetails, cachedAt: Date = Date()) {
        let topicsData = try? JSONEncoder().encode(details.topics)
        self.init(
            id: details.id,
            name: details.name,
            pathWithNamespace: details.pathWithNamespace,
            namespaceName: details.namespaceName,
            projectDescription: details.description,
            starCount: details.starCount,
            forksCount: details.forksCount,
            avatarUrlString: details.avatarUrl?.absoluteString,
            webUrlString: details.webUrl.absoluteString,
            createdAt: details.createdAt,
            lastActivityAt: details.lastActivityAt,
            defaultBranch: details.defaultBranch,
            visibility: details.visibility,
            topicsData: topicsData,
            cachedAt: cachedAt
        )
    }
}

public extension ProjectDetails {
    init(from cached: CachedProjectDetails) {
        let topics = (try? JSONDecoder().decode([String].self, from: cached.topicsData ?? Data())) ?? []
        self.init(
            id: cached.id,
            name: cached.name,
            pathWithNamespace: cached.pathWithNamespace,
            namespaceName: cached.namespaceName,
            description: cached.projectDescription,
            starCount: cached.starCount,
            forksCount: cached.forksCount,
            avatarUrl: cached.avatarUrlString.flatMap(URL.init(string:)),
            webUrl: URL(string: cached.webUrlString) ?? URL(fileURLWithPath: "/"),
            createdAt: cached.createdAt,
            lastActivityAt: cached.lastActivityAt,
            defaultBranch: cached.defaultBranch,
            visibility: cached.visibility,
            topics: topics
        )
    }
}

// MARK: - DTO Conversion Extension

extension ProjectDetails {
    public init(from dto: CachedProjectDetailsDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            pathWithNamespace: dto.pathWithNamespace,
            namespaceName: dto.namespaceName,
            description: dto.description,
            starCount: dto.starCount,
            forksCount: dto.forksCount,
            avatarUrl: dto.avatarUrl,
            webUrl: dto.webUrl,
            createdAt: dto.createdAt,
            lastActivityAt: dto.lastActivityAt,
            defaultBranch: dto.defaultBranch,
            visibility: dto.visibility,
            topics: dto.topics
        )
    }
}
