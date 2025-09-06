//
//  StubUsersAPIClient.swift
//  UsersKitTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork
import UsersData

public struct StubUsersAPIClient: APIClientProtocol {
	public var user: UserDTO?
	public var error: Error?
	public init(user: UserDTO? = nil, error: Error? = nil) {
		self.user = user
		self.error = error
	}
	public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response where Response: Decodable {
		if let error { throw error }
		if Response.self == UserDTO.self, let cast = user as? Response { return cast }
		fatalError("Unsupported endpoint in StubUsersAPIClient")
	}
	public func sendPaginated<Item>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> where Item: Decodable {
		if let error { throw error }
		fatalError("Not used in StubUsersAPIClient")
	}
	public func sendWithHeaders<Response>(_ endpoint: GitLabNetwork.Endpoint<Response>) async throws -> (Response, HTTPURLResponse) where Response: Decodable {
		// For stub implementation, return a basic HTTP 200 response
		let url = URL(string: "https://api.example.com")!
		let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!

		// For most test cases, we can just call the regular send method
		do {
			let response = try await send(endpoint)
			return (response, httpResponse)
		} catch {
			// If the regular send fails, provide a stub response
			throw NSError(
                domain: "StubUsersAPIClient",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "sendWithHeaders not implemented for this endpoint in stub"]
            )
		}
	}
}
