//
//  OAuthService.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct OAuthService: Sendable {
    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func authorizationURL(
        clientId: String,
        redirectURI: String,
        scopes: String,
        codeChallenge: String,
        state: String
    ) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = "/oauth/authorize"
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        return components?.url
    }

    public func exchangeCode(
        code: String,
        redirectURI: String,
        clientId: String,
        codeVerifier: String
    ) async throws -> AuthToken {
        let endpoint = OAuthEndpoints.exchange(
            code: code,
            redirectURI: redirectURI,
            clientId: clientId,
            codeVerifier: codeVerifier
        )
        let request = try endpoint.request(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw NetworkError.server(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoded = try JSONDecoder.gitLab.decode(OAuthTokenDTO.self, from: data)
        return decoded.toDomain()
    }

    public func refreshToken(_ refreshToken: String, clientId: String? = nil) async throws -> AuthToken {
        let endpoint = OAuthEndpoints.refresh(refreshToken: refreshToken, clientId: clientId)
        let request = try endpoint.request(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw NetworkError.server(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoded = try JSONDecoder.gitLab.decode(OAuthTokenDTO.self, from: data)
        return decoded.toDomain()
    }
}
