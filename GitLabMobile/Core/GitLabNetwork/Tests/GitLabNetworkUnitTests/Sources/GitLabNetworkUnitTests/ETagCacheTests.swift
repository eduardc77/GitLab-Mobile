//
//  ETagCacheTests.swift
//  GitLabNetworkUnitTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

@Suite("Transport · ETagCache")
struct ETagCacheSuite {
	@Test("store and read by URL")
	func storeAndRead() async {
		// Given
		let cache = ETagCache()
		let request = URLRequest(url: URL(string: "https://example.test/a")!)

		// When
		await cache.store(etag: "t1", for: request)
		let storedETag = await cache.etag(for: request)

		// Then
		#expect(storedETag == "t1")
	}

	@Test("overwrite updates value")
	func overwrite() async {
		// Given
		let cache = ETagCache()
		let resourceURL = URL(string: "https://example.test/b")!
		let firstETag = "etag-first"
		let secondETag = "etag-second"
		let request = URLRequest(url: resourceURL)

		// When
		await cache.store(etag: firstETag, for: request)
		await cache.store(etag: secondETag, for: request)
		let currentETag = await cache.etag(for: request)

		// Then
		#expect(currentETag == secondETag)
	}

	@Test("clear removes all")
	func clearAll() async {
		// Given
		let cache = ETagCache()
		let resourceURL = URL(string: "https://example.test/x")!
		let request = URLRequest(url: resourceURL)

		// When
		await cache.store(etag: "to-clear", for: request)
		await cache.clear()
		let afterClear = await cache.etag(for: request)

		// Then
		#expect(afterClear == nil)
	}
}
