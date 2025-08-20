//
//  ProfileService.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import UsersData
import UsersDomain

public struct ProfileService: Sendable {
    private let users: any UsersRepository

    public init(users: any UsersRepository) { self.users = users }

    public func loadCurrentUser() async throws -> GitLabUser {
        try await users.currentUser()
    }
}
