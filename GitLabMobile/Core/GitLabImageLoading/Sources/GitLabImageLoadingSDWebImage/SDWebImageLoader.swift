//
//  SDWebImageLoader.swift
//  GitLabImageLoadingSDWebImage
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  SDWebImage-based implementation of ImageLoadingClient
//

import SwiftUI
import SDWebImage
import GitLabImageLoading

public actor SDWebImageLoader: ImageLoadingClient {

    public init() {}

    nonisolated public func configureDefaults() {
        print("🔧 SDWebImageLoader: Configuring defaults")

        // SDWebImage handles multiple configurations safely
        // Basic SDWebImage setup
        SDImageCache.shared.config.maxMemoryCost = 50 * 1024 * 1024 // 50MB
        SDImageCache.shared.config.maxDiskSize = 200 * 1024 * 1024  // 200MB
        SDImageCache.shared.config.maxDiskAge = 7 * 24 * 60 * 60    // 7 days

        // Configure SDWebImage to avoid memory leaks
        SDWebImageManager.shared.optionsProcessor = SDWebImageOptionsProcessor { _, options, context in
            var mutableOptions = options
            // Disable aggressive caching that can cause leaks
            mutableOptions.remove(.retryFailed)
            mutableOptions.remove(.refreshCached) // Don't refresh cached images
            mutableOptions.insert(.avoidAutoSetImage)
            mutableOptions.insert(.lowPriority) // Lower priority to prevent blocking

            // Use modern decode policy instead of deprecated avoidDecodeImage
            var mutableContext = context ?? [:]
            mutableContext[SDWebImageContextOption.imageForceDecodePolicy] = SDImageForceDecodePolicy.never.rawValue

            return SDWebImageOptionsResult(options: mutableOptions, context: mutableContext)
        }

        // Additional memory management settings
        SDImageCache.shared.config.shouldUseWeakMemoryCache = true // Use weak references for memory cache
        SDImageCache.shared.config.shouldCacheImagesInMemory = true // But still cache in memory for performance

        // Simple User-Agent to avoid bot detection
        SDWebImageDownloader.shared.requestModifier = SDWebImageDownloaderRequestModifier { request in
            var request = request
            if request.value(forHTTPHeaderField: "User-Agent") == nil {
                request.setValue(
                    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15",
                    forHTTPHeaderField: "User-Agent"
                )
            }
            return request
        }

        print("✅ SDWebImageLoader: Configuration complete")
    }

    public func loadImage(url: URL?, targetSizePoints: CGSize?) async throws -> Image {
        guard let url else { throw URLError(.badURL) }

        return try await withCheckedThrowingContinuation { continuation in
            let options: SDWebImageOptions = [.scaleDownLargeImages, .avoidAutoSetImage]

            SDWebImageManager.shared.loadImage(
                with: url,
                options: options,
                progress: nil
            ) { image, _, error, _, finished, _ in
                if finished == false { return }

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let image else {
                    continuation.resume(throwing: URLError(.cannotDecodeContentData))
                    return
                }

                #if os(iOS) || os(tvOS) || os(watchOS)
                continuation.resume(returning: Image(uiImage: image))
                #elseif os(macOS)
                continuation.resume(returning: Image(nsImage: image))
                #else
                continuation.resume(throwing: URLError(.cannotDecodeContentData))
                #endif
            }
        }
    }

    /// Cancel loading for a specific URL
    public func cancelLoad(for url: URL) async {
        // SDWebImage handles cancellation internally
    }

    /// Cancel all active loads
    public func cancelAllLoads() async {
        // SDWebImage handles cancellation internally
    }

    /// Clear memory cache
    public func clearMemoryCache() async {
        SDImageCache.shared.clearMemory()
    }

    /// Clear disk cache
    public func clearDiskCache() async {
        await withCheckedContinuation { continuation in
            SDImageCache.shared.clearDisk {
                continuation.resume()
            }
        }
    }

    /// Set authorization header for authenticated requests
    public func setAuthorizationHeader(_ header: String?) {
        print("🔐 SDWebImageLoader: Setting auth header: \(header != nil ? "present" : "nil")")
        SDWebImageDownloader.shared.setValue(header, forHTTPHeaderField: "Authorization")
        print("✅ SDWebImageLoader: Auth header set successfully")
    }

    /// Get current authorization header
    public func getAuthorizationHeader() -> String? {
        let header = SDWebImageDownloader.shared.value(forHTTPHeaderField: "Authorization")
        print("🔍 SDWebImageLoader: Current auth header: \(header != nil ? "present" : "nil")")
        return header
    }
}
