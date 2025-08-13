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
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: String] = [
                "grant_type": "authorization_code",
                "code": code,
                "redirect_uri": redirectURI,
                "client_id": clientId,
                "code_verifier": codeVerifier
            ]
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            return req
        case let .refresh(refreshToken, clientId):
            var req = URLRequest(url: baseURL.appendingPathComponent("/oauth/token"))
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var body: [String: String] = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
            if let clientId { body["client_id"] = clientId }
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            return req
        }
    }

    public func refresh(refreshToken: String) async throws -> OAuthTokenDTO {
        fatalError("Use AuthorizationManager with configured OAuthEndpoints")
    }
}
