//
//  LatestWinsEventQueueTests.swift
//  GitLabUtilitiesUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabUtilities

@Suite("Utilities · LatestWinsEventQueue")
struct LatestWinsEventQueueSuite {
    @Test("Processes only the latest event when multiple are sent quickly")
    func latestEventWins() async {
        // Given
        let queue = LatestWinsEventQueue<Int>()
        var handled: [Int] = []
        queue.start { value in
            try? await Task.sleep(nanoseconds: 50_000_000)
            handled.append(value)
        }

        // When
        queue.send(1)
        queue.send(2)
        queue.send(3)

        // Then
        try? await Task.sleep(nanoseconds: 120_000_000)
        #expect(handled.last == 3)
    }
}
