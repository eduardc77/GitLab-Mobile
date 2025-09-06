//
//  ListMergerTests.swift
//  GitLabUtilitiesUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabUtilities

private struct Item: Identifiable, Sendable, Equatable {
    let id: Int
    let value: String
}

@Suite("Utilities · ListMerger")
struct ListMergerSuite {
    @Test("Appends only non-duplicate items by ID")
    func appendsUnique() async {
        // Given
        let merger = ListMerger()
        let existing = [Item(id: 1, value: "a"), Item(id: 2, value: "b")]
        let newOnes = [Item(id: 2, value: "b2"), Item(id: 3, value: "c")]

        // When
        let merged = await merger.appendUniqueById(existing: existing, newItems: newOnes)

        // Then
        #expect(merged.map { $0.id } == [1, 2, 3])
        #expect(merged[1].value == "b")
    }

    @Test("Trims to maxCount keeping newest suffix")
    func trimsToMaxCount() async {
        // Given
        let merger = ListMerger()
        let existing = [Item(id: 1, value: "1"), Item(id: 2, value: "2")]
        let newOnes = [Item(id: 3, value: "3"), Item(id: 4, value: "4")]

        // When
        let merged = await merger.appendUniqueById(existing: existing, newItems: newOnes, maxCount: 3)

        // Then
        #expect(merged.map { $0.id } == [2, 3, 4])
    }
}
