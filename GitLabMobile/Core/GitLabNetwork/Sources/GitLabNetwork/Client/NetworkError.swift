//
//  NetworkError.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case transport(Error)
    case server(statusCode: Int, data: Data?)
    case decoding(Error)
    case unauthorized
    case trustEvaluationFailed

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .transport(let error):
            return error.localizedDescription
        case .server(let status, _):
            return "Server error (\(status))"
        case .decoding(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized"
        case .trustEvaluationFailed:
            return "Certificate pinning failed"
        }
    }

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.transport, .transport):
            return true // Can't compare Error instances, but we consider them equal if both are transport errors
        case (.server(let lhsCode, _), .server(let rhsCode, _)):
            return lhsCode == rhsCode // Compare status codes only
        case (.decoding, .decoding):
            return true // Can't compare Error instances, but we consider them equal if both are decoding errors
        case (.unauthorized, .unauthorized):
            return true
        case (.trustEvaluationFailed, .trustEvaluationFailed):
            return true
        default:
            return false
        }
    }
}
