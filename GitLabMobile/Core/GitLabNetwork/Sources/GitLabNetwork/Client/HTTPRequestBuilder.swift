//
//  HTTPRequestBuilder.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

///  Centralized helper for building URLs and URLRequests from Endpoint definitions.
public struct HTTPRequestBuilder: Sendable {
    public let baseURL: URL
    public let apiPrefix: String
    public let userAgent: String
    public let acceptLanguage: String

    public init(baseURL: URL, apiPrefix: String, userAgent: String, acceptLanguage: String) {
        self.baseURL = baseURL
        self.apiPrefix = apiPrefix
        self.userAgent = userAgent
        self.acceptLanguage = acceptLanguage
    }

    public func buildURL<Response>(for endpoint: Endpoint<Response>) throws -> URL {
        let fullPath = endpoint.isAbsolutePath ? endpoint.path : (apiPrefix + endpoint.path)
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        // Preserve any percent-encoding already present in the path (e.g., %2F for file_path)
        let basePath = baseURL.path.isEmpty ? "" : baseURL.path
        components.percentEncodedPath = basePath + fullPath
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    public func makeRequest<Response>(url: URL, endpoint: Endpoint<Response>) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(acceptLanguage, forHTTPHeaderField: "Accept-Language")
        if let policy = endpoint.options.cachePolicy { request.cachePolicy = policy }
        if let timeout = endpoint.options.timeout { request.timeoutInterval = timeout }
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
