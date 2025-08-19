//
//  TokenStorage.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabPersistence

public protocol TokenStorage: Sendable {
    func save(_ token: OAuthTokenDTO) async throws
    func load() async throws -> OAuthTokenDTO?
    func clear() async throws
}

public actor KeychainTokenStorage: TokenStorage {
    private let service: String
    private let account: String
    private let secureStore: SecureStore

    public init(
        service: String = Bundle.main.bundleIdentifier ?? "GitLabMobile",
        account: String = "oauth_token",
        secureStore: SecureStore = KeychainSecureStore()
    ) {
        self.service = service
        self.account = account
        self.secureStore = secureStore
    }

    public func save(_ token: OAuthTokenDTO) async throws {
        let data = try JSONEncoder().encode(token)
        try await secureStore.save(data, service: service, account: account)
    }

    public func load() async throws -> OAuthTokenDTO? {
        guard let data = try await secureStore.load(service: service, account: account) else { return nil }
        return try JSONDecoder().decode(OAuthTokenDTO.self, from: data)
    }

    public func clear() async throws {
        try await secureStore.clear(service: service, account: account)
    }
}
