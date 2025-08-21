//
//  RecentQueriesStoreTests.swift
//  GitLabUtilitiesUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabUtilities
import GitLabPersistence
import GitLabUtilitiesTestDoubles

@Suite("Utilities · RecentQueriesStore")
struct RecentQueriesStoreSuite {
    @Test("Trims whitespace, deduplicates case-insensitively, enforces capacity")
    func addAndTrim() async {
        // Given
        let key = "test.recent"
        let store = RecentQueriesStore(key: key, capacity: 3, store: InMemoryKeyValueStore())

        // When
        var list = await store.add("  Hello  ")

        // Then
        #expect(list == ["Hello"])

        // When
        list = await store.add("hello")

        // Then
        #expect(list == ["hello"])

        // When
        list = await store.add("world")
        list = await store.add("swift")
        list = await store.add("gitlab")

        // Then
        #expect(list == ["gitlab", "swift", "world"])
    }

    @Test("Clear removes all values")
    func clearValues() async {
        // Given
        let key = "test.clear"
        let store = RecentQueriesStore(key: key, capacity: 2, store: InMemoryKeyValueStore())

        // When
        _ = await store.add("a")
        await store.clear()
        let loaded = await store.load()

        // Then
        #expect(loaded.isEmpty)
    }
}
