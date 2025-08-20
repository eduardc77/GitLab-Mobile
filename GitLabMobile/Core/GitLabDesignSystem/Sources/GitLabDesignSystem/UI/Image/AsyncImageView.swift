//
//  AsyncImageView.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabImageLoading

public struct AsyncImageView<Placeholder: View>: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let placeholder: Placeholder
    private let onFailure: ((Error) -> Void)?
    // Target size in points; converted to pixels internally
    private let targetSizePoints: CGSize?

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        targetSize: CGSize? = nil,
        @ViewBuilder placeholder: () -> Placeholder,
        onFailure: ((Error) -> Void)? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder()
        self.onFailure = onFailure
        self.targetSizePoints = targetSize
    }

    public var body: some View {
        RemoteImageView(
            url: url,
            contentMode: contentMode,
            targetSize: targetSizePoints,
            placeholder: { placeholder },
            onFailure: onFailure
        )
    }
}
