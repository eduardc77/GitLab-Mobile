//
//  GitLabMobileApp.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import SwiftData
import GitLabImageLoadingKingfisher
import ProjectsCache

@main
struct GitLabMobileApp: App {
    @State private var appEnv = AppEnvironment()
    private let imageLoader = KingfisherImageLoader()

    init() { KingfisherImageLoader().configureDefaults() }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.imageLoader, imageLoader)
                .environment(appEnv.authStore)
                .environment(appEnv.profileStore)
                .environment(appEnv.projectsDependencies)
                .task { await appEnv.authStore.restoreIfPossible() }
        }
        .modelContainer(for: [CachedProject.self, CachedProjectPage.self])
    }
}
