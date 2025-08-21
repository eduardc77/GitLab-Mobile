//
//  AuthorizationManagerTests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork
import GitLabNetworkTestDoubles

@Suite("Auth · AuthorizationManager")
struct AuthorizationManagerSuite {
    private func token(access: String = "a", refresh: String? = nil, expiresIn: Int? = nil, createdAt: TimeInterval? = nil, scope: String? = nil) -> OAuthTokenDTO {
        OAuthTokenDTO(
            accessToken: access,
            tokenType: "Bearer",
            refreshToken: refresh,
            expiresIn: expiresIn,
            createdAt: createdAt,
            scope: scope
        )
    }

    @Test("returns cached valid token")
    func returnsCachedValidToken() async throws {
        // Given
        let storage = StubTokenStorage()
        let sut = AuthorizationManager(
            storage: storage,
            oauthService: OAuthService(baseURL: URL(string: "https://example")!)
        )

        // When
        try await sut.store(token(
            access: "abc",
            refresh: "r",
            expiresIn: 3600,
            createdAt: Date().timeIntervalSince1970)
        )
        let result = try await sut.getValidToken()

        // Then
        #expect(result.accessToken == "abc")
    }

    @Test("expired token without refresh throws unauthorized")
    func expiredNoRefreshThrows() async {
        // Given
        let storage = StubTokenStorage()
        let sut = AuthorizationManager(
            storage: storage,
            oauthService: OAuthService(baseURL: URL(string: "https://example")!)
        )

        // When
        await storage.setLoadResult(token(
            access: "old",
            refresh: nil,
            expiresIn: 1,
            createdAt: Date().addingTimeInterval(-60).timeIntervalSince1970))

        // Then
        await #expect(throws: NetworkError.self) {
            _ = try await sut.getValidToken()
        }
    }
}
