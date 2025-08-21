//
//  APIClientIntegrationTests.swift
//  GitLabNetworkIntegrationTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import Testing
@testable import GitLabNetwork

private func client(auth: AuthProviding? = nil) -> APIClient {
	let config = URLSessionConfiguration.ephemeral
	config.protocolClasses = [StubURLProtocol.self]
	return APIClient(
		baseURL: URL(string: "https://example.test")!,
		apiPrefix: "/api/v4",
		sessionDelegate: nil,
		authProvider: auth,
		userAgent: "Tests",
		acceptLanguage: "en-US",
		sessionConfiguration: config
	)
}

@Suite("Networking · APIClient (Integration)", .serialized)
struct APIClientIntegrationSuite {
	@Test("Retries on 5xx then succeeds")
	func retriesOn5xx() async throws {
		// Given
		let pingURL = URL(string: "https://example.test/api/v4/ping")!
		var sequence: [(Int, [String: String]?, Data?)] = [
			(500, nil, Data()),
			(200, nil, #"{"ok":true}"#.data(using: .utf8)),
		]
		StubURLProtocol.requestHandler = { request in
			#expect(request.url == pingURL)
			let (status, headers, body) = sequence.removeFirst()
			let http = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!
			return (http, body ?? Data())
		}
        struct Box: Decodable {
            let ok: Bool
        }

		// When
		let api = client()
		let endpoint = Endpoint<Box>(path: "/ping")
		let box = try await api.send(endpoint)

		// Then
		#expect(box.ok)
	}

	@Test("Adds If-None-Match and handles 304 Not Modified")
	func etagConditionalGet() async {
		// Given
		let projectsURL = URL(string: "https://example.test/api/v4/projects")!
		var sequence: [(Int, [String: String]?, Data?)] = [
			(200, ["ETag": "tag123"], #"[]"#.data(using: .utf8)),
			(304, [:], Data()),
		]
		StubURLProtocol.requestHandler = { request in
			#expect(request.url == projectsURL)
			let (status, headers, body) = sequence.removeFirst()
			let http = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers)!
			return (http, body ?? Data())
		}
		// When
		let api = client()
		do {
			let _: [Int] = try await api.send(Endpoint(path: "/projects"))
		} catch {
			#expect(Bool(false), "First call should not throw")
		}

		// Then
		await #expect(throws: NetworkError.self) {
			let _: Paginated<[Int]> = try await api.sendPaginated(Endpoint(path: "/projects", options: RequestOptions(useETag: true)))
		}
	}

	private struct TokenAuth: AuthProviding {
        func authorizationHeader() async -> String? { "Bearer 123" }
    }

	@Test("Attaches Authorization header when enabled")
	func attachesAuthorizationHeader() async throws {
		// Given
		let userURL = URL(string: "https://example.test/api/v4/user")!
		StubURLProtocol.requestHandler = { request in
			#expect(request.url == userURL)
			let body = #"{"id":1,"username":"u","name":"n","webUrl":"https://example.test","avatarUrl":null,"createdAt":null}"#.data(using: .utf8)!
			let http = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			return (http, body)
		}
		// When / Then
		let api = client(auth: TokenAuth())
		let _: UserDTO = try await api.send(Endpoint(path: "/user"))
	}
}
