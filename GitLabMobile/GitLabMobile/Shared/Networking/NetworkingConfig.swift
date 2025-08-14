//
//  NetworkingConfig.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct NetworkingConfig: Sendable {
    public let baseURL: URL
    public let apiPrefix: String

    public init(baseURL: URL, apiPrefix: String = "/api/v4") {
        self.baseURL = baseURL
        self.apiPrefix = apiPrefix
    }
}

public enum AppNetworkingConfig {
    public static func loadFromInfoPlist() -> NetworkingConfig {
        if let dict = Bundle.main.infoDictionary,
           let gitLab = dict["GitLabConfiguration"] as? [String: Any],
           let base = gitLab["BaseURL"] as? String,
           let baseURL = URL(string: base) {
            let prefix = (gitLab["APIPrefix"] as? String) ?? "/api/v4"
            return NetworkingConfig(baseURL: baseURL, apiPrefix: prefix)
        }
        // Fallback to gitlab.com
        // Avoid force unwrapping
        let fallbackURL = URL(string: "https://gitlab.com") ?? URL(fileURLWithPath: "/")
        return NetworkingConfig(baseURL: fallbackURL, apiPrefix: "/api/v4")
    }
}
