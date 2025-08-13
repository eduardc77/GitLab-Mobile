//
//  GitLabMobileApp.swift
//  GitLabMobile
//
//  Created by User on 8/12/25.
//

import SwiftUI
import Kingfisher

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
        }
    }

    private static func configureKingfisher() {
        // Reasonable defaults; tuned for device memory headroom
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 30 * 1024 * 1024 // 30 MB
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024 // 200 MB
        cache.diskStorage.config.expiration = .days(7)
        KingfisherManager.shared.downloader.downloadTimeout = 15
    }
}
