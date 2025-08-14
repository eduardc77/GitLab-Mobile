//
//  APIClient+Config.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public extension APIClient {
    init(
        config: NetworkingConfig,
        sessionDelegate: URLSessionDelegate? = nil,
        authProvider: AuthProviding? = nil
    ) {
        self.init(
            baseURL: config.baseURL,
            apiPrefix: config.apiPrefix,
            sessionDelegate: sessionDelegate,
            authProvider: authProvider
        )
    }
}
