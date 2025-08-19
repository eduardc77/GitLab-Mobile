//
//  ProjectDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ProjectDTO: Decodable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let description: String?
    public let starCount: Int?
    public let forksCount: Int?
    public let avatarUrl: String?
    public let webUrl: String
    public let lastActivityAt: Date?
}
