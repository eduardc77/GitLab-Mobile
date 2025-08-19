//
//  UserDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct UserDTO: Decodable, Sendable {
    public let id: Int
    public let username: String
    public let name: String
    public let avatarUrl: URL?
    public let createdAt: Date?
}
