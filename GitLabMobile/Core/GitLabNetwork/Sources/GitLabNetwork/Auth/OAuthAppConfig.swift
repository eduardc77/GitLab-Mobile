//
//  OAuthAppConfig.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct OAuthAppConfig: Sendable {
    public let clientId: String
    public let redirectURI: String
    public let scopes: String

    public init(clientId: String, redirectURI: String, scopes: String) {
        self.clientId = clientId
        self.redirectURI = redirectURI
        self.scopes = scopes
    }
}

public enum AppOAuthConfigLoader {
    public static func loadFromInfoPlist() throws -> OAuthAppConfig {
        guard let dict = Bundle.main.infoDictionary else {
            throw NSError(domain: "GitLabNetwork", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to load Info.plist"])
        }

        guard let oauth = dict["GitLabOAuth"] as? [String: Any] else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 6,
                userInfo: [NSLocalizedDescriptionKey: "Missing GitLabOAuth section in Info.plist"]
            )
        }

        guard let clientId = oauth["ClientID"] as? String else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 7,
                userInfo: [NSLocalizedDescriptionKey: "Missing ClientID in Info.plist"]
            )
        }

        guard let redirect = oauth["RedirectURI"] as? String else {
            throw NSError(
                domain: "GitLabNetwork",
                code: 8,
                userInfo: [NSLocalizedDescriptionKey: "Missing RedirectURI in Info.plist"]
            )
        }

        let scopes = (oauth["Scopes"] as? String) ?? "read_user read_api offline_access"
        return OAuthAppConfig(clientId: clientId, redirectURI: redirect, scopes: scopes)
    }
}
