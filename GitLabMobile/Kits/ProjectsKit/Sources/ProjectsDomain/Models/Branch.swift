//
//  Branch.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct Branch: Identifiable, Equatable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let commit: BranchCommit?
    public let isProtected: Bool
    public let isDefault: Bool

    public init(
        id: String,
        name: String,
        commit: BranchCommit?,
        isProtected: Bool,
        isDefault: Bool
    ) {
        self.id = id
        self.name = name
        self.commit = commit
        self.isProtected = isProtected
        self.isDefault = isDefault
    }
}

public struct BranchCommit: Equatable, Sendable, Hashable {
    public let id: String
    public let shortId: String
    public let title: String
    public let authorName: String
    public let authoredDate: Date

    public init(
        id: String,
        shortId: String,
        title: String,
        authorName: String,
        authoredDate: Date
    ) {
        self.id = id
        self.shortId = shortId
        self.title = title
        self.authorName = authorName
        self.authoredDate = authoredDate
    }
}
