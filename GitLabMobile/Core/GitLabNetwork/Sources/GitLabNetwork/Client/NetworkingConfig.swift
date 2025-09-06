//
//  NetworkingConfig.swift
//  GitLabNetwork
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
    public static func loadFromInfoPlist() throws -> NetworkingConfig {
        guard let dict = Bundle.main.infoDictionary else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to load Info.plist"]
            )
        }

        guard let gitLab = dict["GitLabConfiguration"] as? [String: Any] else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Missing GitLabConfiguration section in Info.plist"]
            )
        }

        guard let base = gitLab["GitLabBaseURL"] as? String else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Missing GitLabBaseURL in Info.plist"]
            )
        }

        guard let baseURL = URL(string: base) else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid GitLabBaseURL format: \(base)"]
            )
        }

        let prefix = (gitLab["GitLabAPIPrefix"] as? String) ?? "/api/v4"
        return NetworkingConfig(baseURL: baseURL, apiPrefix: prefix)
    }
}
