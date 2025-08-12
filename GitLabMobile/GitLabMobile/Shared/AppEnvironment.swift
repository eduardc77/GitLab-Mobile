import SwiftUI

public struct AppEnvironment {
    public let apiClient: APIClient
    public let exploreService: ExploreProjectsService
    public let personalProjectsService: PersonalProjectsService
    public let projectDetailsService: ProjectDetailsService
    public let authManager: AuthorizationManager
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = {
        let config = AppNetworkingConfig.loadFromInfoPlist()
        let oauthService = OAuthService(baseURL: config.baseURL)
        let authManager = AuthorizationManager(storage: KeychainTokenStorage(), oauthService: oauthService)
        // API client with pinning delegate and auth provider
        let sessionDelegate = PinnedSessionDelegate()
        let client = APIClient(config: config, sessionDelegate: sessionDelegate, authProvider: authManager)
        return AppEnvironment(
            apiClient: client,
            exploreService: ExploreProjectsService(api: client),
            personalProjectsService: PersonalProjectsService(api: client),
            projectDetailsService: ProjectDetailsService(api: client),
            authManager: authManager
        )
    }()
}

public extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
