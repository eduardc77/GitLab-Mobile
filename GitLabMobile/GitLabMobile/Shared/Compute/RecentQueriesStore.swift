//
//  RecentQueriesStore.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public actor RecentQueriesStore {
    public static func namespacedKey(_ suffix: String) -> String {
        let base = Bundle.main.bundleIdentifier ?? "com.gitlabmobile"
        return base + "." + suffix
    }

    public enum Keys {
        public static let exploreProjects = RecentQueriesStore.namespacedKey("recent.projects.explore")
        public static let personalProjects = RecentQueriesStore.namespacedKey("recent.projects.personal")
    }

    private let key: String
    private let capacity: Int

    public init(key: String, capacity: Int = StoreDefaults.recentQueriesLimit) {
        self.key = key
        self.capacity = capacity
    }

    public func load() -> [String] {
        (UserDefaults.standard.array(forKey: key) as? [String]) ?? []
    }

    @discardableResult
    public func add(_ raw: String) -> [String] {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return load() }
        var current = load()
        if let idx = current.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            current.remove(at: idx)
        }
        current.insert(trimmed, at: 0)
        if current.count > capacity {
            current.removeLast(current.count - capacity)
        }
        UserDefaults.standard.set(current, forKey: key)
        return current
    }

    public func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
