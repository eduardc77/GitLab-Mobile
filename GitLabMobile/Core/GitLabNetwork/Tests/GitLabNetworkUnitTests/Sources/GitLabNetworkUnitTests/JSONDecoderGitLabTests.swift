//
//  JSONDecoderGitLabTests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

@Suite("Networking · JSONDecoder.gitLab")
struct JSONDecoderSuite {
    @Test("Decodes ISO8601 dates with and without fractional seconds")
    func decodesIsoDates() throws {
        // Given
        let withFractional = Data(#"{"date":"2024-08-18T12:34:56.789Z"}"#.utf8)
        let withoutFractional = Data(#"{"date":"2024-08-18T12:34:56Z"}"#.utf8)

        struct Box: Decodable { let date: Date }

        // When
        let decodedWithFractional = try JSONDecoder.gitLab.decode(Box.self, from: withFractional).date
        let decodedWithoutFractional = try JSONDecoder.gitLab.decode(Box.self, from: withoutFractional).date

        // Then
        #expect(abs(decodedWithFractional.timeIntervalSince1970 - 1723984496.789) < 0.01)
        #expect(abs(decodedWithoutFractional.timeIntervalSince1970 - 1723984496.0) < 0.01)
    }

    @Test("Returns default date for invalid dates")
    func returnsDefaultForInvalidDates() throws {
        // Given
        let invalid = Data(#"{"date":"not-a-date"}"#.utf8)
        struct Box: Decodable { let date: Date }

        // When
        let decoded = try JSONDecoder.gitLab.decode(Box.self, from: invalid)

        // Then
        #expect(decoded.date == Date.distantPast)
    }
}
