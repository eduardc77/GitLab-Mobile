//
//  ETagCache.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

actor ETagCache {
    // MARK: - Configuration
    private let maxSize = 1000
    private let defaultTTL: TimeInterval = 3600 // 1 hour default TTL

    // MARK: - Storage
    private var storage: [String: CacheEntry] = [:]
    private var accessOrder: [String] = [] // Track access order for LRU-like eviction

    private struct CacheEntry {
        let etag: String
        let timestamp: Date
        let ttl: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > ttl
        }
    }

    private func key(for request: URLRequest) -> String? {
        request.url?.absoluteString
    }

    // MARK: - Public API

    func etag(for request: URLRequest) -> String? {
        guard let key = key(for: request) else { return nil }

        guard let entry = storage[key], !entry.isExpired else {
            // Remove expired entry
            storage.removeValue(forKey: key)
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
            return nil
        }

        // Update access order for LRU
        updateAccessOrder(for: key)
        return entry.etag
    }

    func store(etag: String, for request: URLRequest, ttl: TimeInterval? = nil) {
        guard let key = key(for: request) else { return }

        // Clean expired entries before storing (gradual cleanup)
        cleanExpiredEntries()

        // Enforce size limit with efficient LRU eviction
        if storage.count >= maxSize {
            evictEntries(count: max(1, maxSize / 20)) // Remove 5% at a time
        }

        let entry = CacheEntry(
            etag: etag,
            timestamp: Date(),
            ttl: ttl ?? defaultTTL
        )

        storage[key] = entry
        updateAccessOrder(for: key)
    }

    func clear() {
        storage.removeAll(keepingCapacity: false)
        accessOrder.removeAll(keepingCapacity: false)
    }

    func size() -> Int {
        storage.count
    }

    // MARK: - Private Helpers

    private func updateAccessOrder(for key: String) {
        // Move to end (most recently used)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)
    }

    private func cleanExpiredEntries() {
        let expiredKeys = storage
            .filter { $0.value.isExpired }
            .keys

        for key in expiredKeys {
            storage.removeValue(forKey: key)
            if let index = accessOrder.firstIndex(of: key) {
                accessOrder.remove(at: index)
            }
        }
    }

    private func evictEntries(count: Int) {
        // Remove least recently used entries
        let keysToRemove = accessOrder.prefix(count)

        for key in keysToRemove {
            storage.removeValue(forKey: key)
        }

        accessOrder.removeFirst(count)
    }
}
