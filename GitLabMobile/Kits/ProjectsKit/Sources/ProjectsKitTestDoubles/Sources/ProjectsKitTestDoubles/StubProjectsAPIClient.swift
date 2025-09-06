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
    public func sendWithHeaders<Response>(_ endpoint: GitLabNetwork.Endpoint<Response>) async throws -> (Response, HTTPURLResponse) where Response: Decodable {
        // For stub implementation, return a basic HTTP 200 response
        // This is a test double, so we don't actually make network calls
        let url = URL(string: "https://api.example.com")!
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1", headerFields: nil
        )!

        // For most test cases, we can just call the regular send method
        // If that fails, we can provide a default implementation
        do {
            let response = try await send(endpoint)
            return (response, httpResponse)
        } catch {
            // If the regular send fails, provide a stub response
            // This is a fallback for cases where sendWithHeaders is called directly
            throw NSError(
                domain: "StubProjectsAPIClient",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "sendWithHeaders not implemented for this endpoint in stub"]
            )
        }
    }

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
