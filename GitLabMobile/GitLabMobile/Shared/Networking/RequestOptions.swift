//
//  RequestOptions.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct RequestOptions: Sendable, Equatable {
    public var cachePolicy: URLRequest.CachePolicy?
    public var timeout: TimeInterval?
    public var useETag: Bool
    public var attachAuthorization: Bool

    public init(
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeout: TimeInterval? = nil,
        useETag: Bool = false,
        attachAuthorization: Bool = true
    ) {
        self.cachePolicy = cachePolicy
        self.timeout = timeout
        self.useETag = useETag
        self.attachAuthorization = attachAuthorization
    }

    public static let `default` = RequestOptions()
}
