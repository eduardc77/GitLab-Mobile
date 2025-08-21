//
//  HTTPRequestBuilderTests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

@Suite("Auth · HTTPRequestBuilder")
struct HTTPRequestBuilderSuite {
    @Test("Builds URL by prefixing api path and attaching query items")
    func buildsURLWithPrefixAndQueries() throws {
        // Given
        let builder = HTTPRequestBuilder(
            baseURL: URL(string: "https://gitlab.com")!,
            apiPrefix: "/api/v4",
            userAgent: "UA",
            acceptLanguage: "en-US"
        )
        let endpoint = Endpoint<Data>(path: "/projects", queryItems: [URLQueryItem(name: "page", value: "2")])

        // When
        let url = try builder.buildURL(for: endpoint)

        // Then
        #expect(url.absoluteString == "https://gitlab.com/api/v4/projects?page=2")
    }

    @Test("Uses absolute path without api prefix when isAbsolutePath is true")
    func absolutePathBypassesPrefix() throws {
        // Given
        let builder = HTTPRequestBuilder(
            baseURL: URL(string: "https://gitlab.com")!,
            apiPrefix: "/api/v4",
            userAgent: "UA",
            acceptLanguage: "en-US"
        )
        let endpoint = Endpoint<Data>(path: "/oauth/token", isAbsolutePath: true)

        // When
        let url = try builder.buildURL(for: endpoint)

        // Then
        #expect(url.absoluteString == "https://gitlab.com/oauth/token")
    }

    @Test("Sets standard headers and request attributes from options")
    func setsHeadersAndOptions() throws {
        // Given
        let builder = HTTPRequestBuilder(
            baseURL: URL(string: "https://example.com")!,
            apiPrefix: "/api/v4",
            userAgent: "GitLabMobile/Tests",
            acceptLanguage: "en-US"
        )
        let options = RequestOptions(cachePolicy: .reloadIgnoringLocalCacheData, timeout: 12, useETag: false, attachAuthorization: false)
        let endpoint = Endpoint<Data>(path: "/x", headers: ["X-Custom": "1"], options: options)

        // When
        let url = try builder.buildURL(for: endpoint)
        let request = builder.makeRequest(url: url, endpoint: endpoint)

        // Then
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "User-Agent") == "GitLabMobile/Tests")
        #expect(request.value(forHTTPHeaderField: "Accept-Language") == "en-US")
        #expect(request.value(forHTTPHeaderField: "X-Custom") == "1")
        #expect(request.timeoutInterval == 12)
        #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
    }
}
