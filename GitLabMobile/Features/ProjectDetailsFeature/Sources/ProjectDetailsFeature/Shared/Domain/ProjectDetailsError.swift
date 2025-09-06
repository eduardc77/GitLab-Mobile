//
//  ProjectDetailsError.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// Comprehensive error types for project details operations
public enum ProjectDetailsError: LocalizedError, Equatable {
    case networkError(String)
    case authenticationError
    case serverError(String)
    case notFound(String)
    case parsingError(String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return String(localized: "pd.error.network") + ": \(message)"
        case .authenticationError:
            return String(localized: "pd.error.unauthorized")
        case .serverError(let message):
            return String(localized: "pd.error.server") + ": \(message)"
        case .notFound(let resource):
            return String(localized: "pd.error.not_found") + ": \(resource)"
        case .parsingError(let message):
            return String(localized: "pd.error.parsing") + ": \(message)"
        case .unknown(let message):
            return String(localized: "pd.error.unknown") + ": \(message)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again"
        case .authenticationError:
            return "Please log in to access this content"
        case .serverError:
            return "Please try again later or contact support"
        case .notFound:
            return "The requested content may have been moved or deleted"
        case .parsingError:
            return "Please try again or contact support if the issue persists"
        case .unknown:
            return "Please try again"
        }
    }

    public static func == (lhs: ProjectDetailsError, rhs: ProjectDetailsError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError),
             (.authenticationError, .authenticationError),
             (.serverError, .serverError),
             (.notFound, .notFound),
             (.parsingError, .parsingError),
             (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

/// Result type for ProjectDetails operations
public typealias ProjectDetailsResult<T> = Result<T, ProjectDetailsError>
