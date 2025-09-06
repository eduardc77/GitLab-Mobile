//
//  OAuthService.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol OAuthServicing: Sendable {
    func authorizationURL(
        clientId: String,
        redirectURI: String,
        scopes: String,
        codeChallenge: String,
        state: String
    ) -> URL?

    func exchangeCode(
        code: String,
        redirectURI: String,
        clientId: String,
        codeVerifier: String
    ) async throws -> OAuthTokenDTO

    func refreshToken(_ refreshToken: String, clientId: String?) async throws -> OAuthTokenDTO
}

public struct OAuthService: Sendable, OAuthServicing {
    public let baseURL: URL
    private let session: URLSession
    private let requestBuilder: HTTPRequestBuilder

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.requestBuilder = HTTPRequestBuilder(
            baseURL: baseURL,
            apiPrefix: "",
            userAgent: "GitLabMobile/1.0 (iOS)",
            acceptLanguage: Locale.preferredLanguages.first ?? "en-US"
        )
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
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        return components?.url
    }

    public func exchangeCode(
        code: String,
        redirectURI: String,
        clientId: String,
        codeVerifier: String
    ) async throws -> OAuthTokenDTO {
        let endpoint = OAuthEndpoints.exchangeEndpoint(
            code: code,
            redirectURI: redirectURI,
            clientId: clientId,
            codeVerifier: codeVerifier
        )
        // Build URLRequest via shared RequestBuilder (OAuth uses separate URLSession; no auth attached)
        let url = try requestBuilder.buildURL(for: endpoint)
        let request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw NetworkError.server(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoded = try JSONDecoder.gitLab.decode(OAuthTokenDTO.self, from: data)
        return decoded
    }

    public func refreshToken(_ refreshToken: String, clientId: String? = nil) async throws -> OAuthTokenDTO {
        let endpoint = OAuthEndpoints.refreshEndpoint(refreshToken: refreshToken, clientId: clientId)
        let url = try requestBuilder.buildURL(for: endpoint)
        let request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw NetworkError.server(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1, data: data)
        }
        let decoded = try JSONDecoder.gitLab.decode(OAuthTokenDTO.self, from: data)
        return decoded
    }
}
