//
//  AuthToken.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct AuthToken: Codable, Sendable, Equatable {
    public let accessToken: String
    public let tokenType: String
    public let refreshToken: String?
    public let expiresIn: Int?
    public let createdAt: TimeInterval? // seconds since epoch
    public let scope: String?

    public init(
        accessToken: String,
        tokenType: String,
        refreshToken: String?,
        expiresIn: Int?,
        createdAt: TimeInterval?,
        scope: String?
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.createdAt = createdAt
        self.scope = scope
    }

    public var isExpired: Bool {
        guard let expiresIn, let createdAt else { return false }
        let expiry = Date(timeIntervalSince1970: createdAt).addingTimeInterval(TimeInterval(expiresIn))
        return expiry.addingTimeInterval(-30) <= Date()
    }
}
