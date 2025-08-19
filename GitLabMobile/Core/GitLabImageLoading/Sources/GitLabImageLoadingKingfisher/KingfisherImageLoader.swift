//
//  KingfisherImageLoader.swift
//  GitLabImageLoading
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import Kingfisher
import GitLabImageLoading

public actor KingfisherImageLoader: ImageLoadingClient {
    private var currentTask: DownloadTask?
    public init() {}

    public func loadImage(url: URL?, targetSizePoints: CGSize?) async throws -> Image {
        let scale = await MainActor.run { UIScreen.main.scale }
        guard let url = url else { throw URLError(.badURL) }
        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                let source = Source.network(url)
                var options: KingfisherOptionsInfo = []
                if let sizePoints = targetSizePoints {
                    let sizePixels = CGSize(width: sizePoints.width * scale, height: sizePoints.height * scale)
                    options.append(.processor(DownsamplingImageProcessor(size: sizePixels)))
                }
                let task = KingfisherManager.shared.retrieveImage(with: source, options: options) { result in
                    switch result {
                    case .success(let value): continuation.resume(returning: Image(uiImage: value.image))
                    case .failure(let error): continuation.resume(throwing: error)
                    }
                }
                Task { self.store(task: task) }
            }
        }, onCancel: {
            Task { await self.cancelTask() }
        })
    }

    nonisolated public func configureDefaults() {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 30 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)
    }

    private func store(task: DownloadTask?) { self.currentTask = task }
    private func cancelTask() { currentTask?.cancel(); currentTask = nil }
}

// no helpers needed; scale resolved on MainActor in loadImage
