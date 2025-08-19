//
//  AuthProviding.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol AuthProviding: Sendable {
    /// Return full Authorization header value, e.g. "Bearer <token>"
    func authorizationHeader() async -> String?
}
