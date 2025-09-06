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
    func sendWithHeaders<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> (Response, HTTPURLResponse)
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

        // Adaptive memory cache based on device capabilities
        let memoryCapacity = APIClient.adaptiveMemoryCapacity()
        config.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: 0, diskPath: nil)
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

        do {
            let (data, http) = try await performWithRetry(request, endpoint: endpoint)
            return try decode(Response.self, data: data, http: http)
        } catch let error as NetworkError where error == .unauthorized && !endpoint.options.attachAuthorization {
            // Retry once with auth on 401/403 if we didn't already attach auth
            var retryRequest = requestBuilder.makeRequest(url: url, endpoint: endpoint)
            await applyAuthIfAvailable(&retryRequest, endpoint: endpoint, forceAttach: true)
            let (data, http) = try await performWithRetry(retryRequest, endpoint: endpoint)
            return try decode(Response.self, data: data, http: http)
        }
    }

    public func sendPaginated<Item: Decodable>(_ endpoint: Endpoint<[Item]>) async throws -> Paginated<[Item]> {
        let url = try requestBuilder.buildURL(for: endpoint)
        var request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        await applyAuthIfAvailable(&request, endpoint: endpoint)

        do {
            // Use conditional GET (ETag) when enabled to avoid re-downloading unchanged pages
            let (data, http) = try await performWithRetry(request, endpoint: endpoint)
            return try decodePaginated(Item.self, data: data, http: http)
        } catch let NetworkError.server(statusCode: status, data: _) where status == 304 {
            // Not modified: caller should use cached body (we signal via a dedicated error)
            throw NetworkError.server(statusCode: 304, data: nil)
        } catch let error as NetworkError where error == .unauthorized && !endpoint.options.attachAuthorization {
            // Retry once with auth on 401/403 if we didn't already attach auth
            var retryRequest = requestBuilder.makeRequest(url: url, endpoint: endpoint)
            await applyAuthIfAvailable(&retryRequest, endpoint: endpoint, forceAttach: true)
            let (data, http) = try await performWithRetry(retryRequest, endpoint: endpoint)
            return try decodePaginated(Item.self, data: data, http: http)
        }
    }

    public func sendWithHeaders<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> (Response, HTTPURLResponse) {
        let url = try requestBuilder.buildURL(for: endpoint)
        var request = requestBuilder.makeRequest(url: url, endpoint: endpoint)
        await applyAuthIfAvailable(&request, endpoint: endpoint)

        do {
            let (data, http) = try await performWithRetry(request, endpoint: endpoint)
            let response = try decode(Response.self, data: data, http: http)
            return (response, http)
        } catch let error as NetworkError where error == .unauthorized && !endpoint.options.attachAuthorization {
            // Retry once with auth on 401/403 if we didn't already attach auth
            var retryRequest = requestBuilder.makeRequest(url: url, endpoint: endpoint)
            await applyAuthIfAvailable(&retryRequest, endpoint: endpoint, forceAttach: true)
            let (data, http) = try await performWithRetry(retryRequest, endpoint: endpoint)
            let response = try decode(Response.self, data: data, http: http)
            return (response, http)
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

    func applyAuthIfAvailable<Response>(_ request: inout URLRequest, endpoint: Endpoint<Response>, forceAttach: Bool) async {
        guard forceAttach || endpoint.options.attachAuthorization else { return }
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
        case 401, 403:
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
        case 401, 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.server(statusCode: http.statusCode, data: data)
        }
    }

    // MARK: - Adaptive Memory Cache

    /// Calculates adaptive memory capacity based on device capabilities
    /// - Returns: Recommended memory capacity in bytes
    private static func adaptiveMemoryCapacity() -> Int {
        #if os(iOS)
        // Use ProcessInfo for more accurate memory assessment
        let processInfo = ProcessInfo.processInfo

        // Get physical memory in bytes
        let physicalMemory = processInfo.physicalMemory

        // Adaptive sizing based on device memory:
        // - < 2GB: 10MB cache
        // - 2-4GB: 20MB cache
        // - 4-8GB: 40MB cache
        // - 8GB+: 60MB cache
        let memoryCapacity: Int
        switch physicalMemory {
        case ..<2_000_000_000:  // < 2GB
            memoryCapacity = 10 * 1024 * 1024  // 10MB
        case 2_000_000_000..<4_000_000_000:  // 2-4GB
            memoryCapacity = 20 * 1024 * 1024  // 20MB
        case 4_000_000_000..<8_000_000_000:  // 4-8GB
            memoryCapacity = 40 * 1024 * 1024  // 40MB
        default:  // 8GB+
            memoryCapacity = 60 * 1024 * 1024  // 60MB
        }

        return memoryCapacity
        #else
        // macOS or other platforms - use conservative default
        return 20 * 1024 * 1024  // 20MB
        #endif
    }
}
