//
//  GitLabMobileApp.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import SwiftData
import GitLabImageLoadingSDWebImage
import ProjectsCache
import GitLabNavigation

@main
struct GitLabMobileApp: App {
    private let appEnv = AppEnvironment()
    private let appRouter = AppRouter()
    private let imageLoader = SDWebImageLoader()

    // Feature routers
    private var exploreRouter: ExploreRouter
    private var homeRouter: HomeRouter
    private var profileRouter: ProfileRouter

    init() {
        self.imageLoader.configureDefaults()

        exploreRouter = ExploreRouter(appNavigationHandler: appRouter)
        homeRouter = HomeRouter(appNavigationHandler: appRouter)
        profileRouter = ProfileRouter(appNavigationHandler: appRouter)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.imageLoader, imageLoader)
                .environment(appRouter)
                .environment(exploreRouter)
                .environment(homeRouter)
                .environment(profileRouter)
                .environment(appEnv.authStore)
                .environment(appEnv.profileStore)
                .environment(appEnv.projectsDependencies)
                .task { await appEnv.authStore.restoreIfPossible() }
        }
        .modelContainer(for: [
            CachedProject.self,
            CachedProjectPage.self,
        ])
    }
}
