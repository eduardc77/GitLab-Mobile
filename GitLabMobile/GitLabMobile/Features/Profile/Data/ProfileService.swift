//
//  ProfileService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public final class ProfileService {
    private let api: APIClient

    public init(api: APIClient) { self.api = api }

    public func loadCurrentUser() async throws -> GitLabUser {
        let dto: UserDTO = try await api.send(UsersAPI.current())
        return dto.toDomain()
    }
}
