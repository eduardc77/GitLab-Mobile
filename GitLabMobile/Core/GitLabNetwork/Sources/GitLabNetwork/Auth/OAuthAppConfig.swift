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
    public static func loadFromInfoPlist() -> OAuthAppConfig {
        guard let dict = Bundle.main.infoDictionary,
              let oauth = dict["GitLabOAuth"] as? [String: Any],
              let clientId = oauth["ClientID"] as? String,
              let redirect = oauth["RedirectURI"] as? String
        else {
            return OAuthAppConfig(
                clientId: "",
                redirectURI: "gitlabmobile://oauth-callback",
                scopes: "read_user read_api offline_access"
            )
        }
        let scopes = (oauth["Scopes"] as? String) ?? "read_user read_api offline_access"
        return OAuthAppConfig(clientId: clientId, redirectURI: redirect, scopes: scopes)
    }
}
