//
//  OAuthEndpoints.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum OAuthEndpoints {
    case exchange(code: String, redirectURI: String, clientId: String, codeVerifier: String)
    case refresh(refreshToken: String, clientId: String? = nil)

    // Raw URLRequest because OAuth uses different prefix and form encoding
    func request(baseURL: URL) throws -> URLRequest {
        switch self {
        case let .exchange(code, redirectURI, clientId, codeVerifier):
            var req = URLRequest(url: baseURL.appendingPathComponent("/oauth/token"))
            req.httpMethod = "POST"
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let params: [String: String] = [
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirectURI,
                "client_id": clientId,
                "code_verifier": codeVerifier
            ]
            req.httpBody = formURLEncodedBody(params)
            return req
        case let .refresh(refreshToken, clientId):
            var req = URLRequest(url: baseURL.appendingPathComponent("/oauth/token"))
            req.httpMethod = "POST"
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            var params: [String: String] = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
            if let clientId { params["client_id"] = clientId }
            req.httpBody = formURLEncodedBody(params)
            return req
        }
    }

    public func refresh(refreshToken: String) async throws -> OAuthTokenDTO {
        fatalError("Use AuthorizationManager with configured OAuthEndpoints")
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
