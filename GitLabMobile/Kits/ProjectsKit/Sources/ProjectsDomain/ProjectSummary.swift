//
//  ProjectSummary.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

///  Pure domain model for projects. No persistence or networking imports.
public struct ProjectSummary: Identifiable, Decodable, Equatable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let description: String?
    public let starCount: Int
    public let forksCount: Int
    public let avatarUrl: URL?
    public let webUrl: URL
    public let lastActivityAt: Date?

    public init(
        id: Int,
        name: String,
        pathWithNamespace: String,
        description: String?,
        starCount: Int,
        forksCount: Int,
        avatarUrl: URL?,
        webUrl: URL,
        lastActivityAt: Date?
    ) {
        self.id = id
        self.name = name
        self.pathWithNamespace = pathWithNamespace
        self.description = description
        self.starCount = starCount
        self.forksCount = forksCount
        self.avatarUrl = avatarUrl
        self.webUrl = webUrl
        self.lastActivityAt = lastActivityAt
    }
}
