//
//  GitLabMobileApp.swift
//  GitLabMobile
//
//  Created by User on 8/12/25.
//

import SwiftUI

@main
struct GitLabMobileApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appEnvironment, Self.makeEnvironment())
        }
    }

    private static func makeEnvironment() -> AppEnvironment {
        let config = AppNetworkingConfig.loadFromInfoPlist()
        let oauth = OAuthService(baseURL: config.baseURL)
        let authManager = AuthorizationManager(oauthService: oauth)
        let pins = AppPinning.loadPinsFromInfoPlist()
        let sessionDelegate = PinnedSessionDelegate(pins: pins)
        let client = APIClient(config: config, sessionDelegate: sessionDelegate, authProvider: authManager)
        return AppEnvironment(
            apiClient: client,
            exploreService: ExploreProjectsService(api: client),
            personalProjectsService: PersonalProjectsService(api: client),
            projectDetailsService: ProjectDetailsService(api: client),
            authManager: authManager
        )
    }
}
