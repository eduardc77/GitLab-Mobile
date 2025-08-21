//
//  PaginationThrottlerTests.swift
//  GitLabUtilitiesUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabUtilities

@Suite("Utilities · PaginationThrottler")
struct PaginationThrottlerSuite {
    @Test("Allows first trigger and throttles subsequent within window")
    @MainActor
    func throttlesWithinWindow() async {
        // Given
        let throttler = PaginationThrottler()
        let initialTime = Date()

        // When / Then
        #expect(throttler.shouldLoadMore(now: initialTime) == true)
        #expect(throttler.shouldLoadMore(now: initialTime.addingTimeInterval(0.05)) == false)
        #expect(throttler.shouldLoadMore(now: initialTime.addingTimeInterval(StoreDefaults.loadMoreThrottle + 0.01)) == true)
    }
}
