//
//  OAuthEndpoints.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum OAuthEndpoints {
    case exchange(code: String, redirectURI: String, clientId: String, codeVerifier: String)
    case refresh(refreshToken: String, clientId: String? = nil)

    public func refresh(refreshToken: String) async throws -> OAuthTokenDTO {
        fatalError("Use AuthorizationManager with configured OAuthEndpoints")
    }

    // MARK: - Endpoint helpers
    public static func exchangeEndpoint(
        code: String,
        redirectURI: String,
        clientId: String,
        codeVerifier: String
    ) -> Endpoint<OAuthTokenDTO> {
        let params: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientId,
            "code_verifier": codeVerifier,
        ]
        return Endpoint(
            path: "/oauth/token",
            method: .post,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: formURLEncodedBody(params),
            isAbsolutePath: true,
            options: RequestOptions(useETag: false, attachAuthorization: false)
        )
    }

    public static func refreshEndpoint(
        refreshToken: String,
        clientId: String? = nil
    ) -> Endpoint<OAuthTokenDTO> {
        var params: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        if let clientId { params["client_id"] = clientId }
        return Endpoint(
            path: "/oauth/token",
            method: .post,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: formURLEncodedBody(params),
            isAbsolutePath: true,
            options: RequestOptions(useETag: false, attachAuthorization: false)
        )
    }
}

private func formURLEncodedBody(_ params: [String: String]) -> Data? {
    let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
    let encoded = params.map { key, value -> String in
        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
        let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
        return "\(encodedKey)=\(encodedValue)"
    }.joined(separator: "&")
    return encoded.data(using: .utf8)
}
