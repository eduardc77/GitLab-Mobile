//
//  GitLabMobileApp.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import Kingfisher
import SwiftData

@main
struct GitLabMobileApp: App {
    @State private var appEnv = AppEnvironment()

    init() {
        Self.configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appEnv)
                .task { await appEnv.authStore.restoreIfPossible() }
        }
        .modelContainer(for: [CachedProject.self, CachedProjectPage.self])
    }

    private static func configureKingfisher() {
        // Reasonable defaults; tuned for device memory headroom
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 30 * 1024 * 1024 // 30 MB
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024 // 200 MB
        cache.diskStorage.config.expiration = .days(7)
    }
}
