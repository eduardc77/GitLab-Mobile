//
//  KeyValueStore.swift
//  GitLabPersistence
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol KeyValueStore: Sendable {
    func getArray(forKey key: String) async -> [String]?
    func setArray(_ value: [String], forKey key: String) async
    func removeValue(forKey key: String) async
}

/// Lightweight abstraction over key-value storage for cross-feature reuse.
public actor UserDefaultsKeyValueStore: KeyValueStore {
    private let defaults: UserDefaults

    public init() { self.defaults = .standard }

    public func getArray(forKey key: String) async -> [String]? {
        defaults.array(forKey: key) as? [String]
    }

    public func setArray(_ value: [String], forKey key: String) async {
        defaults.set(value, forKey: key)
    }

    public func removeValue(forKey key: String) async {
        defaults.removeObject(forKey: key)
    }
}
