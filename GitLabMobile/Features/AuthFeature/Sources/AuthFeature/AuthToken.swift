//
//  AuthToken.swift
//  AuthFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

public struct AuthToken {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int?
    public let refreshToken: String?
    public let createdAt: Date?

    public init(accessToken: String, tokenType: String, expiresIn: Int?, refreshToken: String?, createdAt: Date?) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.createdAt = createdAt
    }

    public static func from(_ dto: OAuthTokenDTO) -> AuthToken {
        AuthToken(
            accessToken: dto.accessToken,
            tokenType: dto.tokenType,
            expiresIn: dto.expiresIn,
            refreshToken: dto.refreshToken,
            createdAt: dto.createdAt.map { Date(timeIntervalSince1970: $0) }
        )
    }
}
