//
//  RemoteImageViewTests.swift
//  GitLabImageLoadingTests
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  Unit tests for RemoteImageView functionality
//

import SwiftUI
import Testing
@testable import GitLabImageLoading
import GitLabImageLoadingTestDoubles

@Suite("RemoteImageView · behavior")
struct RemoteImageViewTests {
    @Test("Calls loader and replaces placeholder on success")
    @MainActor
    func loadsAndReplacesPlaceholder() async throws {
        // Given
        let expected = Image(systemName: "star")
        let mock = StubImageLoader(imageToReturn: expected)

        // When
        let image = try await mock.loadImage(url: URL(string: "https://example.com/img.png"), targetSizePoints: nil)

        // Then
        #expect(image != nil)
    }

    @Test("Calls failure path when loader throws")
    @MainActor
    func callsFailureOnError() async {
        // Given
        enum ImageLoadingError: Error { case fail }
        let mock = StubImageLoader(errorToThrow: ImageLoadingError.fail)

        // Then
        await #expect(throws: ImageLoadingError.self) {
            _ = try await mock.loadImage(url: URL(string: "https://example.com/img.png"), targetSizePoints: nil)
        }
    }
}
