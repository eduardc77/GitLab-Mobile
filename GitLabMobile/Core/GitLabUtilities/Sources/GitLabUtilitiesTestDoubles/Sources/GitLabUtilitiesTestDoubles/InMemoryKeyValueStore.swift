//
//  InMemoryKeyValueStore.swift
//  GitLabUtilitiesTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabPersistence

/// In-memory implementation of KeyValueStore for testing
public actor InMemoryKeyValueStore: KeyValueStore {
    private var storage: [String: [String]] = [:]

    public init() {}

    public func getArray(forKey key: String) async -> [String]? {
        storage[key]
    }

    public func setArray(_ value: [String], forKey key: String) async {
        storage[key] = value
    }

    public func removeValue(forKey key: String) async {
        storage[key] = nil
    }

    public func clear() {
        storage.removeAll()
    }
}
