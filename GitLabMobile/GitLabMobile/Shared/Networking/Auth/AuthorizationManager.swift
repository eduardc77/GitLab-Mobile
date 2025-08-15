//
//  AuthorizationManager.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol AuthorizationManagerProtocol: Sendable {
    func getValidToken() async throws -> AuthToken
    func store(_ token: AuthToken) async throws
    func signOut() async throws
}

public actor AuthorizationManager: AuthorizationManagerProtocol, AuthProviding {
    private let storage: TokenStorage
    private let oauthService: OAuthService
    private var cached: AuthToken?
    private var refreshTask: Task<AuthToken, Error>?

    public init(storage: TokenStorage = KeychainTokenStorage(), oauthService: OAuthService) {
        self.storage = storage
        self.oauthService = oauthService
    }

    public func store(_ token: AuthToken) async throws {
        try storage.save(token)
        cached = token
    }

    public func signOut() async throws {
        try storage.clear()
        cached = nil
        refreshTask?.cancel(); refreshTask = nil
    }

    public func getValidToken() async throws -> AuthToken {
        if let token = cached ?? (try? storage.load()) {
            cached = token
            if token.isExpired, let refresh = token.refreshToken {
                return try await refreshIfNeeded(refreshToken: refresh)
            }
            return token
        }
        throw NetworkError.unauthorized
    }

    private func refreshIfNeeded(refreshToken: String) async throws -> AuthToken {
        if let task = refreshTask { return try await task.value }
        let task = Task { () throws -> AuthToken in
            defer { refreshTask = nil }
            // Pass clientId if needed in the future; GitLab does not require it by default.
            let refreshed = try await oauthService.refreshToken(refreshToken)
            try storage.save(refreshed)
            cached = refreshed
            return refreshed
        }
        refreshTask = task
        return try await task.value
    }

    // AuthProviding
    public func authorizationHeader() async -> String? {
        do {
            let token = try await getValidToken()
            return "Bearer \(token.accessToken)"
        } catch { return nil }
    }
}
