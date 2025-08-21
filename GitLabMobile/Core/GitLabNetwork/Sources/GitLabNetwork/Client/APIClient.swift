//
//  APIClient.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public protocol APIClientProtocol: Sendable {
    func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response
    func sendPaginated<Item: Decodable>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]>
}

public struct APIClient: Sendable, APIClientProtocol {
    public let baseURL: URL
    public let apiPrefix: String
    public let urlSession: URLSession
    private let authProvider: AuthProviding?
    private let userAgent: String
    private let acceptLanguage: String
    private let eTagCache = ETagCache()
    private let requestBuilder: HTTPRequestBuilder

    public init(
        baseURL: URL,
        apiPrefix: String = "/api/v4",
        sessionDelegate: URLSessionDelegate? = nil,
        authProvider: AuthProviding? = nil,
        userAgent: String = "GitLabMobile/1.0 (iOS)",
        acceptLanguage: String = Locale.preferredLanguages.first ?? "en-US",
        sessionConfiguration: URLSessionConfiguration? = nil
    ) {
        self.baseURL = baseURL
        self.apiPrefix = apiPrefix
        self.userAgent = userAgent
        self.acceptLanguage = acceptLanguage
        let config = sessionConfiguration ?? URLSessionConfiguration.default
        config.waitsForConnectivity = true
        // Respect protocol-directed caching but avoid writing package-local disk files by default
        config.requestCachePolicy = .useProtocolCachePolicy
        // Use memory-only cache (no disk path) to prevent creating on-disk cache directories
        config.urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
        self.urlSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
        self.authProvider = authProvider
        self.requestBuilder = HTTPRequestBuilder(
            baseURL: baseURL,
            apiPrefix: apiPrefix,
            userAgent: userAgent,
            acceptLanguage: acceptLanguage
        )
    }

    public func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let url = try requestBuilder.buildURL(for: endpoint)
        var request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        await applyAuthIfAvailable(&request, endpoint: endpoint)
        let (data, http) = try await performWithRetry(request, endpoint: endpoint)
        return try decode(Response.self, data: data, http: http)
    }

    public func sendPaginated<Item: Decodable>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> {
        let url = try requestBuilder.buildURL(for: endpoint)
        var request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        await applyAuthIfAvailable(&request, endpoint: endpoint)
        // Use conditional GET (ETag) when enabled to avoid re-downloading unchanged pages
        do {
            let (data, http) = try await performWithRetry(request, endpoint: endpoint)
            return try decodePaginated(Item.self, data: data, http: http)
        } catch let NetworkError.server(statusCode: status, data: _) where status == 304 {
            // Not modified: caller should use cached body (we signal via a dedicated error)
            throw NetworkError.server(statusCode: 304, data: nil)
        }
    }
}

// MARK: - Private helpers
private extension APIClient {
    func applyAuthIfAvailable<Response>(_ request: inout URLRequest, endpoint: Endpoint<Response>) async {
        guard endpoint.options.attachAuthorization else { return }
        if let header = await authProvider?.authorizationHeader() {
            request.setValue(header, forHTTPHeaderField: "Authorization")
        }
    }

    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.transport(URLError(.badServerResponse))
            }
            return (data, http)
        } catch {
            if let error = error as? NetworkError { throw error }
            throw NetworkError.transport(error)
        }
    }

    func performWithConditional<Response>(
        _ request: URLRequest,
        endpoint: Endpoint<Response>
    ) async throws -> (Data, HTTPURLResponse) {
        // Apply ETag/If-None-Match if enabled
        var conditioned = request
        if endpoint.options.useETag, let etag = await eTagCache.etag(for: conditioned) {
            conditioned.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }
        let (data, http) = try await perform(conditioned)
        if let newTag = http.value(forHTTPHeaderField: "Etag")
            ?? http.value(forHTTPHeaderField: "ETag") {
            await eTagCache.store(etag: newTag, for: conditioned)
        }
        // If-None-Match should not be used for endpoints that disable ETag via options
        if http.statusCode == 304 {
            throw NetworkError.server(statusCode: 304, data: nil)
        }
        return (data, http)
    }

    func performWithRetry<Response>(
        _ request: URLRequest,
        endpoint: Endpoint<Response>,
        maxAttempts: Int = 3
    ) async throws -> (Data, HTTPURLResponse) {
        var lastError: Error?
        var attempt = 1
        while attempt <= maxAttempts {
            do {
                let (data, http) = try await performWithConditional(request, endpoint: endpoint)
                // Treat 5xx as retryable before decoding
                if (500...599).contains(http.statusCode) {
                    throw NetworkError.server(statusCode: http.statusCode, data: data)
                }
                return (data, http)
            } catch let error as NetworkError {
                lastError = error
                switch error {
                case .server(let status, _):
                    if status >= 500 && status <= 599 {
                        // Backoff: 150ms, 300ms
                        let delayMs = 150 * attempt
                        try? await Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000)
                        attempt += 1
                        continue
                    }
                case .transport:
                    let delayMs = 150 * attempt
                    try? await Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000)
                    attempt += 1
                    continue
                default:
                    throw error
                }
                throw error
            } catch {
                lastError = error
                let delayMs = 150 * attempt
                try? await Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000)
                attempt += 1
            }
        }
        throw lastError ?? NetworkError.transport(URLError(.cannotLoadFromNetwork))
    }

    func decode<R: Decodable>(_ type: R.Type, data: Data, http: HTTPURLResponse) throws -> R {
        switch http.statusCode {
        case 200..<300:
            if R.self == Data.self, let raw = data as? R { return raw }
            do { return try JSONDecoder.gitLab.decode(R.self, from: data) } catch {
                if let debugString = String(data: data, encoding: .utf8) {
                    let urlString = http.url?.absoluteString ?? "-"
                    let bodySnippet = debugString.prefix(500)
                    print("Decoding failed for URL: \(urlString)\nBody snippet: \(bodySnippet)")
                }
                throw NetworkError.decoding(error)
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.server(statusCode: http.statusCode, data: data)
        }
    }

    func decodePaginated<Item: Decodable>(
        _ type: Item.Type,
        data: Data,
        http: HTTPURLResponse
    ) throws -> Paginated<[Item]> {
        switch http.statusCode {
        case 200..<300:
            do {
                let items = try JSONDecoder.gitLab.decode([Item].self, from: data)
                let pageInfo = PaginationParser.parse(from: http)
                return Paginated(items: items, pageInfo: pageInfo)
            } catch {
                if let debugString = String(data: data, encoding: .utf8) {
                    let urlString = http.url?.absoluteString ?? "-"
                    let bodySnippet = debugString.prefix(500)
                    print("Paginated decode failed for URL: \(urlString)\nBody snippet: \(bodySnippet)")
                }
                throw NetworkError.decoding(error)
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.server(statusCode: http.statusCode, data: data)
        }
    }
}
