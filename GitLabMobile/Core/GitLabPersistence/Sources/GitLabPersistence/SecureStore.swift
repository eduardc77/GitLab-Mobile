//
//  SecureStore.swift
//  GitLabPersistence
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Security

public enum SecureStoreError: Error, Sendable {
    case osStatus(OSStatus)
}

public protocol SecureStore: Sendable {
    func save(_ data: Data, service: String, account: String) async throws
    func load(service: String, account: String) async throws -> Data?
    func clear(service: String, account: String) async throws
}

/// Abstraction over secure storage (Keychain-backed implementation provided).
public actor KeychainSecureStore: SecureStore {
    private let accessible: CFString
    private let synchronizable: Bool

    public init(
        accessible: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        synchronizable: Bool = false
    ) {
        self.accessible = accessible
        self.synchronizable = synchronizable
    }

    public func save(_ data: Data, service: String, account: String) async throws {
        // Match any existing item (do not include kSecAttrAccessible in the match)
        var match: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        if synchronizable {
            match[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        }

        // Delete old value, fail on unexpected errors
        let deleteStatus = SecItemDelete(match as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            throw SecureStoreError.osStatus(deleteStatus)
        }

        // Add new value with explicit accessibility (and optional sync)
        var add = match
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = accessible
        if synchronizable {
            add[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else { throw SecureStoreError.osStatus(status) }
    }

    public func load(service: String, account: String) async throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        if synchronizable {
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        }
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else { throw SecureStoreError.osStatus(status) }
        return data
    }

    public func clear(service: String, account: String) async throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        if synchronizable {
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        }
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecureStoreError.osStatus(status)
        }
    }
}
