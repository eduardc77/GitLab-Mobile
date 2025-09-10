//
//  AppEnvironment.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation
import GitLabNetwork
import GitLabLogging
import UserProjectsFeature
import AuthFeature
import ProfileFeature
import ProjectsDomain
import ProjectsData
import ProjectsCache
import UsersData
import Foundation

@MainActor
@Observable
public final class AppEnvironment {
    public let apiClient: APIClient
    public let authManager: AuthorizationManager
    public let authStore: AuthenticationStore
    public let profileService: ProfileService
    public let profileStore: ProfileStore
    public let projectsDependencies: ProjectsDependencies

    public init() {
        // Load configuration with error handling
        var config: NetworkingConfig
        let oauthConfig: OAuthAppConfig
        let pins: Set<String>

        do {
            config = try AppNetworkingConfig.loadFromInfoPlist()
            oauthConfig = try AppOAuthConfigLoader.loadFromInfoPlist()
            pins = AppPinning.loadPinsFromInfoPlist()
        } catch {
            // Log the error and use fallback values
            AppLog.config.warning("Configuration loading failed: \(error.localizedDescription)")
            AppLog.config.info("Using fallback configuration values")

            // Fallback configuration - create URL safely
            let fallbackURL: URL
            if let url = URL(string: "https://gitlab.com") {
                fallbackURL = url
            } else {
                // This should never happen with a hardcoded string, but handle it gracefully
                fallbackURL = URL(fileURLWithPath: "/") // fallback to root directory
            }
            config = NetworkingConfig(
                baseURL: fallbackURL,
                apiPrefix: "/api/v4"
            )
            oauthConfig = OAuthAppConfig(
                clientId: "",
                redirectURI: "gitlabmobile://oauth-callback",
                scopes: "read_user read_api offline_access"
            )
            pins = []
        }

        // Initialize services with validated configuration
        let oauth = OAuthService(baseURL: config.baseURL)
        let authManager = AuthorizationManager(oauthService: oauth, clientId: oauthConfig.clientId)
        let sessionDelegate = PinnedSessionDelegate(pins: pins)
        let client = APIClient(config: config, sessionDelegate: sessionDelegate, authProvider: authManager)

        self.apiClient = client
        self.authManager = authManager
        self.authStore = AuthenticationStore(oauthService: oauth, authManager: authManager, oauthConfig: oauthConfig)
        self.profileService = ProfileService(users: DefaultUsersRepository(api: client))
        self.profileStore = ProfileStore(authStore: self.authStore, service: self.profileService)

        // Repository wiring
        let remoteDS = DefaultProjectsRemoteDataSource(api: client)
        let localDS = DefaultProjectsLocalDataSource()
        let projectDetailsLocalDS = DefaultProjectDetailsLocalDataSource()
        // Create README service outside of actor for better separation of concerns
        let readmeService = READMEService(remote: remoteDS, markdownRenderer: client)
        let projectsRepository = DefaultProjectsRepository(
            remote: remoteDS,
            local: localDS,
            projectDetailsLocal: projectDetailsLocalDS,
            readmeService: readmeService
        )

        // Create issues repository
        let issuesRepository = IssuesRepository(networkClient: client)

        // Create observable dependency container
        self.projectsDependencies = ProjectsDependencies(
            repository: projectsRepository,
            issuesRepository: issuesRepository
        )
    }
}
