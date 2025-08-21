//
//  DefaultUsersRepository.swift
//  UsersKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import UsersDomain
import GitLabNetwork

public struct DefaultUsersRepository: UsersRepository {
    private let api: APIClientProtocol
    public init(api: APIClientProtocol) { self.api = api }

    public func currentUser() async throws -> GitLabUser {
        let dto: UserDTO = try await api.send(UsersEndpoints.current())
        return dto.toDomain()
    }
}
