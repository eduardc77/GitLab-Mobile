//
//  OAuthTokenDTO.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct OAuthTokenDTO: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let refreshToken: String?
    public let expiresIn: Int?
    public let createdAt: TimeInterval?
    public let scope: String?

    public init(accessToken: String, tokenType: String, refreshToken: String?, expiresIn: Int?, createdAt: TimeInterval?, scope: String?) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.createdAt = createdAt
        self.scope = scope
    }
}
