//
//  UserDTO+Mapping.swift
//  UsersKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License 2.0. See LICENSE file.
//

import UsersDomain
import GitLabNetwork

extension UserDTO {
    func toDomain() -> GitLabUser {
        GitLabUser(
            id: id,
            username: username,
            name: name,
            avatarUrl: avatarUrl,
            createdAt: createdAt
        )
    }
}
