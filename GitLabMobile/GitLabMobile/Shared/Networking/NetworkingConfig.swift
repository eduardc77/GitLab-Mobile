import Foundation

public struct NetworkingConfig: Sendable {
    public let baseURL: URL
    public let apiPrefix: String

    public init(baseURL: URL, apiPrefix: String = "/api/v4") {
        self.baseURL = baseURL
        self.apiPrefix = apiPrefix
    }
}

public enum AppNetworkingConfig {
    public static func loadFromInfoPlist() -> NetworkingConfig {
        if let dict = Bundle.main.infoDictionary,
           let gl = dict["GitLabConfiguration"] as? [String: Any],
           let base = gl["BaseURL"] as? String,
           let baseURL = URL(string: base) {
            let prefix = (gl["APIPrefix"] as? String) ?? "/api/v4"
            return NetworkingConfig(baseURL: baseURL, apiPrefix: prefix)
        }
        // Fallback to gitlab.com
        return NetworkingConfig(baseURL: URL(string: "https://gitlab.com")!, apiPrefix: "/api/v4")
    }
}

