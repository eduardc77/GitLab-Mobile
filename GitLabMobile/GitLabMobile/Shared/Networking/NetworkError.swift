//
//  NetworkError.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
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
}
