//
//  PaginationParserTests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

private func http(headers: [String: String]) -> HTTPURLResponse {
    let url = URL(string: "https://gitlab.com/x")!
    return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
}

@Suite("Networking · PaginationParser")
struct PaginationParserSuite {
    @Test("Parses X-* pagination headers when present")
    func parsesExplicitHeaders() {
        // Given
        let response = http(headers: [
            "X-Page": "2",
            "X-Per-Page": "20",
            "X-Next-Page": "3",
            "X-Prev-Page": "1",
            "X-Total": "100",
            "X-Total-Pages": "5",
        ])
        // When
        let info = PaginationParser.parse(from: response)

        // Then
        #expect(info?.page == 2)
        #expect(info?.perPage == 20)
        #expect(info?.nextPage == 3)
        #expect(info?.prevPage == 1)
        #expect(info?.total == 100)
        #expect(info?.totalPages == 5)
    }

    @Test("Falls back to Link header for next/prev when X-* are missing")
    func parsesFromLinkHeader() {
        // Given
        let response = http(headers: [
            "X-Page": "1",
            "X-Per-Page": "20",
            "Link": "<https://gitlab.com/api/v4/projects?page=2>; rel=\"next\", <https://gitlab.com/api/v4/projects?page=0>; rel=\"prev\"",
        ])
        // When
        let info = PaginationParser.parse(from: response)

        // Then
        #expect(info?.nextPage == 2)
        #expect(info?.prevPage == 0)
    }
}
