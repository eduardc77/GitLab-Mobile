//
//  UserDTO.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

struct UserDTO: Decodable {
    let id: Int
    let username: String
    let name: String
    let avatarUrl: URL?
    let createdAt: Date?

    func toDomain() -> GitLabUser {
        GitLabUser(id: id, username: username, name: name, avatarUrl: avatarUrl, createdAt: createdAt)
    }
}

