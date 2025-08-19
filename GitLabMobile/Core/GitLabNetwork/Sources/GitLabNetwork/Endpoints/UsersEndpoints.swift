//
//  UsersEndpoints.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum UsersEndpoints {
    public static func current() -> Endpoint<UserDTO> {
        Endpoint(path: "/user", options: RequestOptions(useETag: true))
    }
}
