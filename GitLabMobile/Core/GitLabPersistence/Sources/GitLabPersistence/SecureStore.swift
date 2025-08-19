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
    public init() {}

    public func save(_ data: Data, service: String, account: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw SecureStoreError.osStatus(status) }
    }

    public func load(service: String, account: String) async throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else { throw SecureStoreError.osStatus(status) }
        return data
    }

    public func clear(service: String, account: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
