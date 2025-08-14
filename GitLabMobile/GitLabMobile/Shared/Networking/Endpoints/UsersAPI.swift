//
//  UsersAPI.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

enum UsersAPI {
    static func current() -> Endpoint<UserDTO> {
        Endpoint(path: "/user")
    }
}

