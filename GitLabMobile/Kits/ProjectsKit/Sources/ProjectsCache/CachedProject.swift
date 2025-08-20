//
//  CachedProject.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import SwiftData
import ProjectsDomain

@Model
public final class CachedProject {
    @Attribute(.unique) public var id: Int
    public var name: String
    public var pathWithNamespace: String
    public var projectDescription: String?
    public var starCount: Int
    public var forksCount: Int
    public var avatarUrlString: String?
    public var webUrlString: String
    public var lastActivityAt: Date?

    public init(
        id: Int,
        name: String,
        pathWithNamespace: String,
        projectDescription: String?,
        starCount: Int,
        forksCount: Int,
        avatarUrlString: String?,
        webUrlString: String,
        lastActivityAt: Date?
    ) {
        self.id = id
        self.name = name
        self.pathWithNamespace = pathWithNamespace
        self.projectDescription = projectDescription
        self.starCount = starCount
        self.forksCount = forksCount
        self.avatarUrlString = avatarUrlString
        self.webUrlString = webUrlString
        self.lastActivityAt = lastActivityAt
    }

    public convenience init(from summary: ProjectSummary) {
        self.init(
            id: summary.id,
            name: summary.name,
            pathWithNamespace: summary.pathWithNamespace,
            projectDescription: summary.description,
            starCount: summary.starCount,
            forksCount: summary.forksCount,
            avatarUrlString: summary.avatarUrl?.absoluteString,
            webUrlString: summary.webUrl.absoluteString,
            lastActivityAt: summary.lastActivityAt
        )
    }
}

public extension ProjectSummary {
    init(from cached: CachedProject) {
        self.init(
            id: cached.id,
            name: cached.name,
            pathWithNamespace: cached.pathWithNamespace,
            description: cached.projectDescription,
            starCount: cached.starCount,
            forksCount: cached.forksCount,
            avatarUrl: cached.avatarUrlString.flatMap(URL.init(string:)),
            webUrl: URL(string: cached.webUrlString) ?? URL(fileURLWithPath: "/"),
            lastActivityAt: cached.lastActivityAt
        )
    }
}
