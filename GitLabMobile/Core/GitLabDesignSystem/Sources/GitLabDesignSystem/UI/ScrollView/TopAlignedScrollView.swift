//
//  TopAlignedScrollView.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct TopAlignedScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: () -> Content

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollView(axes, showsIndicators: showsIndicators) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    content()
                    Spacer(minLength: 0)
                }
                .frame(
                    minWidth: axes.contains(.horizontal) ? geo.size.width : nil,
                    minHeight: axes.contains(.vertical) ? geo.size.height : nil,
                    alignment: .topLeading
                )
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}
