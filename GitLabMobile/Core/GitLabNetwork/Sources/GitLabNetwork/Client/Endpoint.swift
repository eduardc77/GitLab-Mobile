//
//  Endpoint.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct Endpoint<Response: Decodable> {
    // Relative path by default; can be absolute when `isAbsolutePath == true`
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var headers: [String: String]
    public var body: Data?
    public var options: RequestOptions

    // If true, `path` is treated as absolute and no prefix will be applied
    public var isAbsolutePath: Bool

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        isAbsolutePath: Bool = false,
        options: RequestOptions = .default
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.isAbsolutePath = isAbsolutePath
        self.options = options
    }
}
