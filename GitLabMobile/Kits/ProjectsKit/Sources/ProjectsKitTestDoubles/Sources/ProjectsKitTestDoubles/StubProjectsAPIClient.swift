//
//  StubProjectsAPIClient.swift
//  ProjectsKitTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork
import ProjectsData

public struct StubProjectsAPIClient: APIClientProtocol {
	public var paginatedProjects: Paginated<[ProjectDTO]> = Paginated(items: [], pageInfo: nil)

	public init() {}

	public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response where Response: Decodable {
		fatalError("Unexpected non-paginated call in StubProjectsAPIClient")
	}
	public func sendPaginated<Item>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> where Item: Decodable {
		if Item.self == ProjectDTO.self, let cast = paginatedProjects as? Paginated<[Item]> { return cast }
		fatalError("Unsupported type in StubProjectsAPIClient")
	}
}
