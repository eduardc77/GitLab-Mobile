//
//  PKCETests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

@Suite("Auth · PKCE")
struct PKCESuite {
	@Test("verifier has requested length and charset")
	func verifierLengthAndCharset() {
		// Given
		let requestedLength = 64
		let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")

		// When
		let codeVerifier = PKCE.generateCodeVerifier(length: requestedLength)

		// Then
		#expect(codeVerifier.count == requestedLength)
		#expect(codeVerifier.unicodeScalars.allSatisfy { allowedCharacters.contains($0) })
	}

	@Test("base64url encoding removes +/=")
	func base64UrlEncoding() {
		// Given
		let rawData = Data([0xff, 0xef, 0xfa])

		// When
		let base64URL = PKCE.base64URLEncode(rawData)

		// Then
		#expect(!base64URL.contains("+") && !base64URL.contains("/") && !base64URL.contains("="))
	}

	@Test("known verifier produces known challenge")
	func knownVector() {
		// Given
		let verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
		let expected = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"

		// When
		let challenge = PKCE.generateCodeChallenge(from: verifier)

		// Then
		#expect(challenge == expected)
	}
}
