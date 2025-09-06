//
//  READMEService.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabNetwork
import GitLabLogging
import ProjectsDomain

/// Service responsible for discovering and rendering README files.
/// Handles the business logic of finding README files and rendering them using GitLab's Markdown API.
public actor READMEService {
    private let remote: ProjectsRemoteDataSource
    private let markdownRenderer: APIClientProtocol

    // Common README file patterns to search for (comprehensive list)
    private let readmePatterns = [
        "README.md",
        "README.rst",
        "README.txt",
        "README.adhoc",
        "README",
        "readme.md",
        "readme.rst",
        "readme.txt",
        "readme",
        "Readme.md",      // Common variation with capital R
        "ReadMe.md",      // Another common variation
        "README.MD",      // All caps extension
        "readme.MD",      // Lowercase with caps extension
        "Readme.MD",      // Mixed case
        "README.markdown", // Alternative extension
        "readme.markdown",
        "Readme.markdown",
        "README.mkd",     // Another markdown extension
        "readme.mkd",
        "Readme.mkd",
    ]

    // Common documentation directory patterns (comprehensive list)
    private let docDirectories = [
        "docs/",
        ".github/",
        "doc/",
        ".gitlab/",
        "documentation/",
        "Documentation/",
        "wiki/",
        "Wiki/",
        "help/",
        "Help/",
        "manual/",
        "Manual/",
        "guide/",
        "Guide/",
        "tutorials/",
        "Tutorials/",
        "examples/",
        "Examples/",
    ]

    public init(
        remote: ProjectsRemoteDataSource,
        markdownRenderer: APIClientProtocol
    ) {
        self.remote = remote
        self.markdownRenderer = markdownRenderer
    }

    /// Finds and renders a README for the given project.
    /// Searches for common README file patterns and renders the first one found.
    ///
    /// - Parameters:
    ///   - projectId: The GitLab project ID
    ///   - ref: The git reference (branch/tag) to fetch from. If nil, uses default branch.
    /// - Returns: A fully rendered ProjectREADME with both raw and HTML content
    /// - Throws: READMEError if no README is found or rendering fails
    public func fetchREADME(for projectId: Int, ref: String?) async throws -> ProjectREADME {
        AppLog.projects.debug("🔍 Starting comprehensive README discovery for project \(projectId), ref: \(ref ?? "default")")
        AppLog.projects.debug("📋 Will search \(self.readmePatterns.count) filename patterns and \(self.docDirectories.count) directory patterns")
        AppLog.projects.debug("Starting README discovery for project \(projectId), ref: \(ref ?? "default")")

        // Get the effective ref (default branch if not specified)
        let effectiveRef = try await resolveRef(projectId: projectId, requestedRef: ref)
        AppLog.projects.debug("Using ref: \(effectiveRef)")

        // Try to find a README file
        let (readmePath, baseDir) = try await findREADMEFile(projectId: projectId, ref: effectiveRef)
        AppLog.projects.debug("Found README at path: \(readmePath), baseDir: \(baseDir ?? "none")")

        // Fetch raw content
        let rawData = try await remote.fetchREADMEContent(projectId: projectId, path: readmePath, ref: effectiveRef)
        guard let rawMarkdown = String(data: rawData, encoding: .utf8), !rawMarkdown.isEmpty else {
            throw READMEError.invalidContent
        }

        // Render to HTML using GitLab's Markdown API
        let renderedHTML = try await renderMarkdown(rawMarkdown, projectId: projectId)
        AppLog.projects.debug("Successfully rendered README, HTML length: \(renderedHTML.count)")

        return ProjectREADME(
            projectId: projectId,
            rawMarkdown: rawMarkdown,
            renderedHTML: renderedHTML,
            filePath: readmePath,
            ref: effectiveRef,
            baseDir: baseDir
        )
    }

    /// Resolves the effective git reference to use.
    private func resolveRef(projectId: Int, requestedRef: String?) async throws -> String {
        if let ref = requestedRef, !ref.isEmpty {
            return ref
        }
        guard let defaultBranch = try await remote.fetchDefaultBranch(projectId: projectId) else {
            throw READMEError.notFound
        }
        return defaultBranch
    }

    /// Searches for a README file in common locations.
    private func findREADMEFile(projectId: Int, ref: String) async throws -> (path: String, baseDir: String?) {
        // First try root-level README files
        for pattern in readmePatterns {
            do {
                _ = try await remote.fetchREADMEContent(projectId: projectId, path: pattern, ref: ref)
                return (pattern, nil) // No base directory for root files
            } catch {
                // File doesn't exist, continue searching
                continue
            }
        }

        // Try documentation directories
        for docDir in docDirectories {
            for pattern in readmePatterns {
                let fullPath = docDir + pattern
                do {
                    _ = try await remote.fetchREADMEContent(projectId: projectId, path: fullPath, ref: ref)
                    return (fullPath, docDir.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
                } catch {
                    // File doesn't exist, continue searching
                    continue
                }
            }
        }

        throw READMEError.notFound
    }

    /// Renders markdown content to HTML using GitLab's Markdown API.
    private func renderMarkdown(_ markdown: String, projectId: Int) async throws -> String {
        // First try to get project info to get the project path for proper image resolution
        let projectInfo = try await remote.fetchProjectDetails(id: projectId)
        let projectPath = projectInfo.pathWithNamespace

        let response = try await markdownRenderer.send(
            Endpoint<MarkdownHTMLResponse>.renderMarkdown(
                markdown: markdown,
                projectPath: projectPath,
                gfm: true,
                sanitized: false,
                attachAuthorization: true
            )
        )

        guard !response.html.isEmpty else {
            throw READMEError.renderingFailed("GitLab Markdown API returned empty HTML")
        }

        return response.html
    }
}
