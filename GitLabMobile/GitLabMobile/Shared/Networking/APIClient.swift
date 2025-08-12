import Foundation

public struct APIClient {
    public let baseURL: URL
    public let apiPrefix: String
    public let urlSession: URLSession
    private let authProvider: AuthProviding?

    public init(
        baseURL: URL,
        apiPrefix: String = "/api/v4",
        sessionDelegate: URLSessionDelegate? = nil,
        authProvider: AuthProviding? = nil
    ) {
        self.baseURL = baseURL
        self.apiPrefix = apiPrefix
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.urlSession = URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
        self.authProvider = authProvider
    }

    public func send<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let url = try buildURL(for: endpoint)
        var request = makeRequest(url: url, endpoint: endpoint)
        await applyAuthIfAvailable(&request)
        let (data, http) = try await perform(request)
        return try decode(Response.self, data: data, http: http)
    }
}

// MARK: - Private helpers
private extension APIClient {
    func buildURL<Response>(for endpoint: Endpoint<Response>) throws -> URL {
        let fullPath = endpoint.isAbsolutePath ? endpoint.path : (apiPrefix + endpoint.path)
        guard var components = URLComponents(url: baseURL.appendingPathComponent(fullPath),
                                             resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    func makeRequest<Response>(url: URL, endpoint: Endpoint<Response>) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }

    func applyAuthIfAvailable(_ request: inout URLRequest) async {
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

    func decode<R: Decodable>(_ type: R.Type, data: Data, http: HTTPURLResponse) throws -> R {
        switch http.statusCode {
        case 200..<300:
            if R.self == Data.self, let raw = data as? R { return raw }
            do { return try JSONDecoder.gitLab.decode(R.self, from: data) } catch { throw NetworkError.decoding(error) }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.server(statusCode: http.statusCode, data: data)
        }
    }
}

