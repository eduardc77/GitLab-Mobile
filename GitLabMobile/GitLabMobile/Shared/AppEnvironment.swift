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
final class AppEnvironment {
    let apiClient: APIClient
    let exploreService: ExploreProjectsService
    let personalProjectsService: PersonalProjectsService
    let projectDetailsService: ProjectDetailsService
    let authManager: AuthorizationManager

    init() {
        let config = AppNetworkingConfig.loadFromInfoPlist()
        let oauth = OAuthService(baseURL: config.baseURL)
        let authManager = AuthorizationManager(oauthService: oauth)
        let pins = AppPinning.loadPinsFromInfoPlist()
        let sessionDelegate = PinnedSessionDelegate(pins: pins)
        let client = APIClient(config: config, sessionDelegate: sessionDelegate, authProvider: authManager)
        self.apiClient = client
        self.exploreService = ExploreProjectsService(api: client)
        self.personalProjectsService = PersonalProjectsService(api: client)
        self.projectDetailsService = ProjectDetailsService(api: client)
        self.authManager = authManager
    }

    func createExploreProjectsStore() -> ExploreProjectsStore {
        ExploreProjectsStore(service: exploreService)
    }
}
