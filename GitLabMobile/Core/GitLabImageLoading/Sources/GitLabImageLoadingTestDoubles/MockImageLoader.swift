//
//  MockImageLoader.swift
//  GitLabImageLoadingTestDoubles
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Mock implementation of ImageLoadingClient for testing
//

import SwiftUI
import GitLabImageLoading

public struct StubImageLoader: ImageLoadingClient {
    public var imageToReturn: Image?
    public var errorToThrow: Error?

    public init(imageToReturn: Image? = nil, errorToThrow: Error? = nil) {
        self.imageToReturn = imageToReturn
        self.errorToThrow = errorToThrow
    }

    public func loadImage(url: URL?, targetSizePoints: CGSize?) async throws -> Image {
        if let errorToThrow { throw errorToThrow }
        return imageToReturn ?? Image(systemName: "photo")
    }

    public func configureDefaults() {}

    public func cancelLoad(for url: URL) async {}

    public func cancelAllLoads() async {}

    public func clearMemoryCache() async {}

    public func clearDiskCache() async {}
}
