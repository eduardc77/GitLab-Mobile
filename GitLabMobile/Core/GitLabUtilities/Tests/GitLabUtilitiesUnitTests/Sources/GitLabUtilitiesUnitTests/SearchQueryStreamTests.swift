//
//  SearchQueryStreamTests.swift
//  GitLabUtilitiesUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabUtilities

@Suite("Utilities · SearchQueryStream")
struct SearchQueryStreamSuite {
    @Test("Debounces and removes duplicates, delivering only final trimmed value")
    @MainActor
    func debouncesAndDeduplicates() async {
        // Given
        let stream = SearchQueryStream()
        var received: [String] = []
        stream.start(debounceMilliseconds: 50) { value in
            received.append(value)
        }

        // When
        stream.yield("  he")
        stream.yield(" he")
        stream.yield("hello  ")

        // Wait
        try? await Task.sleep(nanoseconds: 120_000_000)

        // Then
        #expect(received == ["hello"])
    }
}
