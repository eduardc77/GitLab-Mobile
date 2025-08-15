//
//  PKCE.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import CryptoKit

public enum PKCE {
    public static func generateCodeVerifier(length: Int = 64) -> String {
        precondition(length > 0, "PKCE code verifier length must be positive")
        let allowed = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        var randomNumberGenerator = SystemRandomNumberGenerator()
        var result: [Character] = []
        result.reserveCapacity(length)
        for _ in 0..<length {
            if let character = allowed.randomElement(using: &randomNumberGenerator) {
                result.append(character)
            } else {
                result.append(Character("a"))
            }
        }
        return String(result)
    }

    public static func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let digest = SHA256.hash(data: data)
        return base64URLEncode(Data(digest))
    }

    public static func base64URLEncode(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
