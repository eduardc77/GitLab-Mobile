//
//  AuthorizationManager.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabPersistence
import GitLabLogging

public protocol AuthorizationManagerProtocol: Sendable {
    func getValidToken() async throws -> OAuthTokenDTO
    func store(_ token: OAuthTokenDTO) async throws
    func signOut() async throws
}

public actor AuthorizationManager: AuthorizationManagerProtocol, AuthProviding {
    private let storage: TokenStorage
    private let oauthService: OAuthService
    private let oauthClientId: String?
    private var cached: OAuthTokenDTO?
    private var refreshTask: Task<OAuthTokenDTO, Error>?

    public init(
        storage: TokenStorage = KeychainTokenStorage(),
        oauthService: OAuthService,
        clientId: String? = nil
    ) {
        self.storage = storage
        self.oauthService = oauthService
        self.oauthClientId = clientId
    }

    public func store(_ token: OAuthTokenDTO) async throws {
        try await storage.save(token)
        cached = token
        AppLog.auth.log("store token: has_refresh=\(token.refreshToken != nil ? "1" : "0") exp=\(String(describing: token.expiresIn)) created=\(String(describing: token.createdAt))")
    }

    public func signOut() async throws {
        try await storage.clear()
        cached = nil
        refreshTask?.cancel(); refreshTask = nil
    }

    public func getValidToken() async throws -> OAuthTokenDTO {
        if let token = cached {
            if isExpired(token) {
                if let refresh = token.refreshToken {
                    AppLog.auth.log("token expired in-memory; will refresh")
                    return try await refreshIfNeeded(refreshToken: refresh)
                } else {
                    AppLog.auth.error("token expired in-memory and no refresh token; require re-auth")
                    throw NetworkError.unauthorized
                }
            }
            AppLog.auth.debug("using cached in-memory token (valid)")
            return token
        }

        if let loaded = try await storage.load() {
            cached = loaded
            if isExpired(loaded) {
                if let refresh = loaded.refreshToken {
                    AppLog.auth.log("token expired from storage; will refresh")
                    return try await refreshIfNeeded(refreshToken: refresh)
                } else {
                    AppLog.auth.error("token expired from storage and no refresh token; require re-auth")
                    throw NetworkError.unauthorized
                }
            }
            AppLog.auth.debug("using token from storage (valid)")
            return loaded
        }
        throw NetworkError.unauthorized
    }

    private func refreshIfNeeded(refreshToken: String) async throws -> OAuthTokenDTO {
        if let task = refreshTask { return try await task.value }
        let task = Task { () throws -> OAuthTokenDTO in
            defer { refreshTask = nil }
            AppLog.auth.log("refresh start")
            let refreshed = try await oauthService.refreshToken(refreshToken, clientId: oauthClientId)
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

    private func isExpired(_ token: OAuthTokenDTO) -> Bool {
        guard let expiresIn = token.expiresIn, let createdAt = token.createdAt else { return false }

        // Handle both seconds and milliseconds timestamps
        // GitLab typically returns timestamps in seconds, but some OAuth providers may use milliseconds
        let createdDate: Date
        if createdAt > 1_000_000_000_000 { // If timestamp is > 1 trillion, it's likely milliseconds
            createdDate = Date(timeIntervalSince1970: createdAt / 1000)
        } else {
            createdDate = Date(timeIntervalSince1970: createdAt)
        }

        let expiry = createdDate.addingTimeInterval(TimeInterval(expiresIn))
        return expiry.addingTimeInterval(-30) <= Date() // 30 second buffer
    }

    // AuthProviding
    public func authorizationHeader() async -> String? {
        do {
            let token = try await getValidToken()
            return "Bearer \(token.accessToken)"
        } catch { return nil }
    }
}
