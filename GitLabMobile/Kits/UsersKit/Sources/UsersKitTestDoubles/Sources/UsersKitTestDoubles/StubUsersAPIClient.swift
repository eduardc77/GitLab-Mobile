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
}
