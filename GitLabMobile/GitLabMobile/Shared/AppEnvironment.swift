//
//  AppEnvironment.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation

@MainActor
@Observable
public final class AppEnvironment {
    public let apiClient: APIClient
    public let projectDetailsService: ProjectDetailsService
    public let projectsRepository: any ProjectsRepository
    public let authManager: AuthorizationManager
    public let authStore: AuthenticationStore
    public let profileService: ProfileService
    public let profileStore: ProfileStore

    public init() {
        let config = AppNetworkingConfig.loadFromInfoPlist()
        let oauth = OAuthService(baseURL: config.baseURL)
        let authManager = AuthorizationManager(oauthService: oauth)
        let pins = AppPinning.loadPinsFromInfoPlist()
        let sessionDelegate = PinnedSessionDelegate(pins: pins)
        let client = APIClient(config: config, sessionDelegate: sessionDelegate, authProvider: authManager)
        self.apiClient = client
        self.projectDetailsService = ProjectDetailsService(api: client)
        self.authManager = authManager
        let oauthConfig = AppOAuthConfigLoader.loadFromInfoPlist()
        self.authStore = AuthenticationStore(oauthService: oauth, authManager: authManager, oauthConfig: oauthConfig)
        self.profileService = ProfileService(api: client)
        self.profileStore = ProfileStore(authStore: self.authStore, service: self.profileService)

        // Repository wiring
        let remoteDS = DefaultProjectsRemoteDataSource(api: client)
        let localDS = DefaultProjectsLocalDataSource()
        self.projectsRepository = DefaultProjectsRepository(remote: remoteDS, local: localDS)
    }
}
