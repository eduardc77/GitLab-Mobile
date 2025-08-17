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
        try await storage.save(token)
        cached = token
        AppLog.auth.log("store token: has_refresh=\(token.refreshToken != nil ? "1" : "0") exp=\(String(describing: token.expiresIn)) created=\(String(describing: token.createdAt))")
    }

    public func signOut() async throws {
        try await storage.clear()
        cached = nil
        refreshTask?.cancel(); refreshTask = nil
    }

    public func getValidToken() async throws -> AuthToken {
        if let token = cached {
            if token.isExpired, let refresh = token.refreshToken {
                AppLog.auth.log("token expired in-memory; will refresh")
                return try await refreshIfNeeded(refreshToken: refresh)
            }
            AppLog.auth.debug("using cached in-memory token (valid)")
            return token
        }

        if let loaded = try await storage.load() {
            cached = loaded
            if loaded.isExpired, let refresh = loaded.refreshToken {
                AppLog.auth.log("token expired from storage; will refresh")
                return try await refreshIfNeeded(refreshToken: refresh)
            }
            AppLog.auth.debug("using token from storage (valid)")
            return loaded
        }
        throw NetworkError.unauthorized
    }

    private func refreshIfNeeded(refreshToken: String) async throws -> AuthToken {
        if let task = refreshTask { return try await task.value }
        let task = Task { () throws -> AuthToken in
            defer { refreshTask = nil }
            AppLog.auth.log("refresh start")
            // Pass clientId if needed in the future; GitLab does not require it by default.
            let refreshed = try await oauthService.refreshToken(refreshToken)
            try await storage.save(refreshed)
            cached = refreshed
            AppLog.auth.log("refresh success: has_refresh=\(refreshed.refreshToken != nil ? "1" : "0") exp=\(String(describing: refreshed.expiresIn))")
            return refreshed
        }
        refreshTask = task
        do {
            return try await task.value
        } catch {
            AppLog.auth.error("refresh failed: \(String(describing: error))")
            throw error
        }
    }

    // AuthProviding
    public func authorizationHeader() async -> String? {
        do {
            let token = try await getValidToken()
            return "Bearer \(token.accessToken)"
        } catch { return nil }
    }
}
