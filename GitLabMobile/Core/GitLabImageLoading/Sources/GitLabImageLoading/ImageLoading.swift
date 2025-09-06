//
//  ImageLoading.swift
//  GitLabImageLoading
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

// Minimal abstraction + environment for optional DI
public protocol ImageLoadingClient: Sendable {
    func loadImage(url: URL?, targetSizePoints: CGSize?) async throws -> Image
    func configureDefaults()
    func cancelLoad(for url: URL) async
    func cancelAllLoads() async
    func clearMemoryCache() async
    func clearDiskCache() async
}

private struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue: (any ImageLoadingClient)? = nil
}

public extension EnvironmentValues {
    var imageLoader: (any ImageLoadingClient)? {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }
}

public struct RemoteImageView<Placeholder: View>: View {
    @Environment(\.imageLoader) private var loader
    private let url: URL?
    private let contentMode: ContentMode
    private let targetSize: CGSize?
    private let placeholder: Placeholder
    private let onFailure: ((Error) -> Void)?

    @State private var loadedImage: Image?
    @State private var currentTask: Task<Void, Never>?

    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        targetSize: CGSize? = nil,
        @ViewBuilder placeholder: () -> Placeholder,
        onFailure: ((Error) -> Void)? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.targetSize = targetSize
        self.placeholder = placeholder()
        self.onFailure = onFailure
    }

    public var body: some View {
        Group {
            if let image = loadedImage {
                image.resizable().aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .task(id: url) {
            // Cancel any existing task
            currentTask?.cancel()

            guard let loader, let url else { return }

            do {
                let image = try await loader.loadImage(url: url, targetSizePoints: targetSize)
                // Only update if task wasn't cancelled
                if !Task.isCancelled {
                    loadedImage = image
                }
            } catch {
                // Only call onFailure if task wasn't cancelled
                if !Task.isCancelled {
                    onFailure?(error)
                }
            }
        }
        .onDisappear {
            // Cancel task when view disappears - no need to store reference
            currentTask?.cancel()
        }
        .onChange(of: url) { oldValue, newValue in
            // Clear image when URL changes
            if oldValue != newValue {
                loadedImage = nil
            }
        }
    }
}
