//
//  ProjectDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct NamespaceDTO: Decodable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let path: String
    public let kind: String
    public let fullPath: String?
    public let parentId: Int?
    public let avatarUrl: String?
    public let webUrl: String?
}

public struct ProjectDTO: Decodable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let namespace: NamespaceDTO?
    public let description: String?
    public let starCount: Int?
    public let forksCount: Int?
    public let avatarUrl: String?
    public let webUrl: String
    public let createdAt: Date?
    public let lastActivityAt: Date?
    public let defaultBranch: String?
    public let visibility: String?
    public let topics: [String]?
}
