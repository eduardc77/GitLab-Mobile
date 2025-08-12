import Foundation

public extension APIClient {
    init(
        config: NetworkingConfig,
        sessionDelegate: URLSessionDelegate? = nil,
        authProvider: AuthProviding? = nil
    ) {
        self.init(
            baseURL: config.baseURL,
            apiPrefix: config.apiPrefix,
            sessionDelegate: sessionDelegate,
            authProvider: authProvider
        )
    }
}
