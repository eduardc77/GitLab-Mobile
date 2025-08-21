//
//  UsersTestData.swift
//  UsersKitTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

private struct UserDTOJSON: Encodable {
    let id: Int
    let username: String
    let name: String
    let avatarUrl: String?
    let createdAt: String // ISO8601
}

public enum UsersTestData {
    // Generic builder
    public static func userDTO(
        id: Int = 1,
        username: String = "john_doe",
        name: String = "John Doe",
        avatarUrl: String? = nil,
        createdAtISO8601: String = "2024-01-01T00:00:01Z"
    ) throws -> UserDTO {
        let json = UserDTOJSON(id: id, username: username, name: name, avatarUrl: avatarUrl, createdAt: createdAtISO8601)
        let data = try JSONEncoder().encode(json)
        return try JSONDecoder.gitLab.decode(UserDTO.self, from: data)
    }

    // Named fixtures
    public static func canonicalUser() throws -> UserDTO { try userDTO() }
    public static func userWithAvatar() throws -> UserDTO { try userDTO(avatarUrl: "https://example.com/avatar.png") }
    public static func userMissingOptionalFields() throws -> UserDTO { try userDTO(avatarUrl: nil) }
    public static func epochUser() throws -> UserDTO { try userDTO(createdAtISO8601: "1970-01-01T00:00:00Z") }
}
