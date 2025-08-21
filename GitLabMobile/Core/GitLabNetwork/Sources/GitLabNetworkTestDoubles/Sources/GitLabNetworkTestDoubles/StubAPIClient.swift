//
//  StubAPIClient.swift
//  GitLabNetworkTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork

/// Stub implementation of APIClientProtocol for testing
public struct StubAPIClient: APIClientProtocol {
    private var responses: [String: any Sendable] = [:]
    private var errors: [String: Error] = [:]

    public init() {}

    public func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response where Response: Decodable {
        let key = endpoint.path
        if let error = errors[key] { throw error }
        guard let response = responses[key] as? Response else {
            fatalError("No response configured for endpoint: \(key)")
        }
        return response
    }

    public func sendPaginated<Item>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> where Item: Decodable {
        let key = endpoint.path
        if let error = errors[key] { throw error }
        guard let response = responses[key] as? Paginated<[Item]> else {
            fatalError("No paginated response configured for endpoint: \(key)")
        }
        return response
    }

    public mutating func configureResponse<T: Sendable>(for path: String, response: T) {
        responses[path] = response
    }

    public mutating func configureError(for path: String, error: Error) {
        errors[path] = error
    }
}
