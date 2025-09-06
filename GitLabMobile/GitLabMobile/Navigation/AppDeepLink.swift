//
//  AppDeepLink.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  App-specific deep link implementation using shared types
//

import Foundation
import GitLabNavigation

// Extend the shared AppDeepLinkParser with app-specific parsing
extension AppDeepLinkParser {
    public static func parseGitLabMobileURL(_ url: URL) -> AppDeepLink? {
        guard let scheme = url.scheme?.lowercased() else { return nil }
        // Custom scheme: gitlabmobile://project/123 or gitlabmobile://tab/explore
        if scheme == "gitlabmobile" || scheme == "glmobile" {
            let host = url.host?.lowercased()
            let parts = url.path.split(separator: "/", omittingEmptySubsequences: true)
            if host == "project", let first = parts.first, let id = Int(first) {
                return .projectDetails(id)
            }
            if host == "tab", let first = parts.first {
                switch first.lowercased() {
                case "home": return .tab(0)
                case "explore": return .tab(1)
                case "profile": return .tab(2)
                case "notifications": return .tab(3)
                default: break
                }
            }
        }
        return nil
    }
}
