//
//  ETagCache.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

actor ETagCache {
    private var storage: [String: String] = [:]

    private func key(for request: URLRequest) -> String? {
        request.url?.absoluteString
    }

    func etag(for request: URLRequest) -> String? {
        guard let key = key(for: request) else { return nil }
        return storage[key]
    }

    func store(etag: String, for request: URLRequest) {
        guard let key = key(for: request) else { return }
        storage[key] = etag
    }

    func clear() {
        storage.removeAll(keepingCapacity: false)
    }
}
