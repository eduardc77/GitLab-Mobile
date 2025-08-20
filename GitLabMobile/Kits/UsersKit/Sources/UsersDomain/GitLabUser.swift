//
//  GitLabUser.swift
//  UsersKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct GitLabUser: Sendable, Equatable {
    public let id: Int
    public let username: String
    public let name: String
    public let avatarUrl: URL?
    public let createdAt: Date?

    public init(id: Int, username: String, name: String, avatarUrl: URL?, createdAt: Date?) {
        self.id = id
        self.username = username
        self.name = name
        self.avatarUrl = avatarUrl
        self.createdAt = createdAt
    }
}
