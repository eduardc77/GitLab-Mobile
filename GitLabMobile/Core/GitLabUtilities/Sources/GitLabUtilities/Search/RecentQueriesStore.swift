//
//  RecentQueriesStore.swift
//  GitLabUtilities
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabPersistence

public actor RecentQueriesStore {
    public static func namespaceKey(_ suffix: String) -> String {
        let base = Bundle.main.bundleIdentifier ?? "com.gitlabmobile"
        return base + "." + suffix
    }

    public enum Keys {
        public static let exploreProjects = RecentQueriesStore.namespaceKey("recent.projects.explore")
        public static let personalProjects = RecentQueriesStore.namespaceKey("recent.projects.personal")
    }

    private let key: String
    private let capacity: Int
    private let store: KeyValueStore

    public init(key: String, capacity: Int = StoreDefaults.recentQueriesLimit, store: KeyValueStore = UserDefaultsKeyValueStore()) {
        self.key = key
        self.capacity = capacity
        self.store = store
    }

    public func load() async -> [String] {
        await store.getArray(forKey: key) ?? []
    }

    @discardableResult
    public func add(_ raw: String) async -> [String] {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return await load() }
        var current = await load()
        if let idx = current.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            current.remove(at: idx)
        }
        current.insert(trimmed, at: 0)
        if current.count > capacity {
            current.removeLast(current.count - capacity)
        }
        await store.setArray(current, forKey: key)
        return current
    }

    public func clear() async {
        await store.removeValue(forKey: key)
    }
}
