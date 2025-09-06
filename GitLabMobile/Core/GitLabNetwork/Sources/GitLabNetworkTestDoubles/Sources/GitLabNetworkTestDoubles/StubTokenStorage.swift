//
//  StubTokenStorage.swift
//  GitLabNetworkTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

public actor StubTokenStorage: TokenStorage {
    public var saved: OAuthTokenDTO?
    public var loadResult: OAuthTokenDTO?
    public var cleared = false
    public init() {}
    public func save(_ token: OAuthTokenDTO) async throws { saved = token }
    public func load() async throws -> OAuthTokenDTO? { loadResult }
    public func clear() async throws { cleared = true; saved = nil; loadResult = nil }
    public func setLoadResult(_ token: OAuthTokenDTO?) { loadResult = token }
}
