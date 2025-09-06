//
//  ProjectREADME.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// Domain model representing a project's README content.
/// Provides both raw markdown and rendered HTML with proper GitLab styling.
public struct ProjectREADME: Identifiable, Equatable, Sendable {
    /// Unique identifier for the README (same as project ID)
    public let id: Int

    /// The project this README belongs to
    public let projectId: Int

    /// Raw markdown content as fetched from the repository
    public let rawMarkdown: String

    /// HTML content rendered using GitLab's Markdown API with official styling
    public let renderedHTML: String

    /// The file path where the README was found (e.g., "README.md", "docs/README.md")
    public let filePath: String

    /// The git reference (branch/tag) the README was fetched from
    public let ref: String

    /// The base directory relative to which relative links should be resolved
    public let baseDir: String?

    /// When the README was last fetched
    public let fetchedAt: Date

    public init(
        projectId: Int,
        rawMarkdown: String,
        renderedHTML: String,
        filePath: String,
        ref: String,
        baseDir: String?,
        fetchedAt: Date = Date()
    ) {
        self.id = projectId
        self.projectId = projectId
        self.rawMarkdown = rawMarkdown
        self.renderedHTML = renderedHTML
        self.filePath = filePath
        self.ref = ref
        self.baseDir = baseDir
        self.fetchedAt = fetchedAt
    }
}

/// Errors that can occur during README operations
public enum READMEError: LocalizedError, Sendable {
    case notFound
    case renderingFailed(String)
    case networkError(Error)
    case invalidContent

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "README file not found"
        case .renderingFailed(let reason):
            return "Failed to render README: \(reason)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidContent:
            return "README content is invalid or corrupted"
        }
    }
}
