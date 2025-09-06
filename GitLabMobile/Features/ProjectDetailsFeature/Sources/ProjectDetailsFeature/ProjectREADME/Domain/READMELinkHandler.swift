//
//  READMELinkHandler.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import GitLabLogging

/// Handles URL routing logic for README links
@MainActor
final class READMELinkHandler {
    private let projectPath: String
    private let projectId: Int

    init(projectPath: String, projectId: Int) {
        self.projectPath = projectPath
        self.projectId = projectId
    }

    /// Determines how to handle a tapped URL in the README
    /// - Parameter url: The URL that was tapped
    /// - Returns: LinkAction indicating how to handle the URL
    func handleLink(_ url: URL) -> LinkAction {
        AppLog.projects.debug("Link tapped: \(url.absoluteString)")

        // 1. Handle anchor links within the README
        if isAnchorLink(url) {
            if let fragment = url.fragment, !fragment.isEmpty {
                return .scrollToAnchor(fragment)
            }
        }

        // 2. Handle relative links within the project
        if isRelativeLink(url) {
            return .navigateToProjectFile(url.path)
        }

        // 3. Handle GitLab project links
        if let gitLabAction = handleGitLabLink(url) {
            return gitLabAction
        }

        // 4. External links - open externally
        return .openExternally(url)
    }

    private func isAnchorLink(_ url: URL) -> Bool {
        url.absoluteString.hasPrefix("#") ||
        (url.scheme == nil && url.fragment != nil)
    }

    private func isRelativeLink(_ url: URL) -> Bool {
        url.scheme == nil || url.host == nil
    }

    private func handleGitLabLink(_ url: URL) -> LinkAction? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host, host.contains("gitlab.com") else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/").filter { !$0.isEmpty }

        guard pathComponents.count >= 2 else { return nil }

        let linkProjectPath = "\(pathComponents[0])/\(pathComponents[1])"

        if linkProjectPath == projectPath {
            // Same project - handle internally
            return handleSameProjectLink(components, pathComponents)
        } else {
            // Different project - open externally
            AppLog.projects.debug("Different project link: \(linkProjectPath) (current: \(self.projectPath))")
            return .openExternally(url)
        }
    }

    private func handleSameProjectLink(_ components: URLComponents, _ pathComponents: [String.SubSequence]) -> LinkAction {
        // README anchor links
        if isReadmeAnchorLink(pathComponents, components.fragment) {
            if let fragment = components.fragment {
                return .scrollToAnchor(fragment)
            }
        }

        // Other files in the same project
        if isProjectFileLink(pathComponents) {
            let filePath = pathComponents.dropFirst(2).joined(separator: "/")
            AppLog.projects.debug("Same project file link: \(filePath)")
            return .navigateToProjectFile(filePath)
        }

        // Other project pages (issues, MRs, etc.) - open externally for now
        AppLog.projects.debug("Same project page link: \(components.path)")
        guard let urlString = components.url?.absoluteString, !urlString.isEmpty,
              let url = URL(string: urlString) else {
            AppLog.projects.error("Failed to create URL from components: \(components)")
            return .ignore
        }
        return .openExternally(url)
    }

    private func isReadmeAnchorLink(_ pathComponents: [String.SubSequence], _ fragment: String?) -> Bool {
        guard pathComponents.count >= 3,
              pathComponents[2] == "-" || pathComponents[2] == "blob",
              let lastComponent = pathComponents.last,
              isReadmeFile(String(lastComponent)),
              fragment != nil else {
            return false
        }
        return true
    }

    private func isProjectFileLink(_ pathComponents: [String.SubSequence]) -> Bool {
        pathComponents.count >= 3 &&
        (pathComponents[2] == "-" || pathComponents[2] == "blob")
    }

    private func isReadmeFile(_ filename: String) -> Bool {
        // Get filename without path
        let fileNameOnly = (filename as NSString).lastPathComponent

        // Supported README extensions
        let supportedExtensions = ["md", "rst", "txt", "adhoc"]

        // Check for exact "readme" filename (no extension) - case insensitive
        if fileNameOnly.caseInsensitiveCompare("readme") == .orderedSame {
            return true
        }

        // Check for README with supported extensions
        let fileNameWithoutExtension = (fileNameOnly as NSString).deletingPathExtension
        let fileExtension = (fileNameOnly as NSString).pathExtension

        // Case-insensitive comparison for filename
        let isReadmeFile = fileNameWithoutExtension.caseInsensitiveCompare("readme") == .orderedSame

        // Case-insensitive check for extension
        let hasSupportedExtension = supportedExtensions.contains { ext in
            fileExtension.caseInsensitiveCompare(ext) == .orderedSame
        }

        return isReadmeFile && hasSupportedExtension
    }
}

/// Actions that can be taken when a link is tapped
enum LinkAction: Equatable {
    case scrollToAnchor(String)
    case navigateToProjectFile(String)
    case openExternally(URL)
    case ignore
}
