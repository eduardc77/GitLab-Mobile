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
