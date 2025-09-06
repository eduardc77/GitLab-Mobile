//
//  AppNavigation.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  App-level navigation types and deep linking
//

import Foundation

// MARK: - Deep Link Types

/// Deep link types for the app
public enum AppDeepLink: Equatable {
    case tab(Int) // tab index
    case projectDetails(Int) // project ID
}

// MARK: - Deep Link Parser

/// Deep link parser
public struct AppDeepLinkParser {
    public static func parse(_ url: URL) -> AppDeepLink? {
        // Simple URL parsing - can be extended for more complex schemes
        let pathComponents = url.pathComponents
        if pathComponents.contains("projects"), let projectIdString = pathComponents.last, let projectId = Int(projectIdString) {
            return .projectDetails(projectId)
        }
        // Parse tab from query parameter or path
        if let tabIndex = parseTabIndex(from: url) {
            return .tab(tabIndex)
        }
        return nil
    }

    private static func parseTabIndex(from url: URL) -> Int? {
        // Parse tab index from URL query or path
        if let tabParam = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "tab" })?
            .value, let tabIndex = Int(tabParam) {
            return tabIndex
        }
        // Or parse from path like /tab/0
        let pathComponents = url.pathComponents
        if pathComponents.count >= 3, pathComponents[1] == "tab", let tabIndex = Int(pathComponents[2]) {
            return tabIndex
        }
        return nil
    }
}

// MARK: - Deep Link Result

/// Result of processing a deep link
public enum DeepLinkResult {
    case navigateToProject(projectId: Int, tab: AppTab)
    case navigateToProjects(tab: AppTab)
    case switchToTab(AppTab)
    case invalid

    public var targetTab: AppTab? {
        switch self {
        case .navigateToProject(_, let tab): return tab
        case .navigateToProjects(let tab): return tab
        case .switchToTab(let tab): return tab
        case .invalid: return nil
        }
    }
}
