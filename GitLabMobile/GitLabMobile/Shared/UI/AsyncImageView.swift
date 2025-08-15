//
//  AsyncImageView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import Kingfisher

public struct AsyncImageView<Placeholder: View>: View {
    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let placeholder: Placeholder
    private let onFailure: ((KingfisherError) -> Void)?
    // Target size in points; converted to pixels internally
    private let targetSizePoints: CGSize?

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        targetSize: CGSize? = nil,
        @ViewBuilder placeholder: () -> Placeholder,
        onFailure: ((KingfisherError) -> Void)? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder()
        self.onFailure = onFailure
        self.targetSizePoints = targetSize
    }

    public var body: some View {
        KFImage.url(url)
            .placeholder { placeholder }
            .onFailure { onFailure?($0) }
            .downsampled(to: targetSizePoints)
            .cacheOriginalImage(false)
            .cancelOnDisappear(true)
            .resizable()
            .aspectRatio(contentMode: contentMode)

    }
}

private extension KFImage {
    func downsampled(to targetSizePoints: CGSize?) -> KFImage {
        guard let sizePoints = targetSizePoints else { return self }
        let scale = UIScreen.main.scale
        let sizePixels = CGSize(width: sizePoints.width * scale, height: sizePoints.height * scale)
        return setProcessor(DownsamplingImageProcessor(size: sizePixels))
    }
}
