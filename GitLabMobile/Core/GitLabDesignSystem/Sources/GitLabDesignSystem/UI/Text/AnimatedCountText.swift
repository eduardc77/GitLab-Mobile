//
//  AnimatedCountText.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

/// Animated count text with smooth transitions
/// Displays numeric values with smooth animations when they change
public struct AnimatedCountText: View {
    let count: Int?
    let isLoading: Bool

    @State private var displayedCount: Int?

    public init(count: Int?, isLoading: Bool = false) {
        self.count = count
        self.isLoading = isLoading
    }

    public var body: some View {
        Text(displayedCount.map { "\($0)" } ?? String(localized: .DesignSystemL10n.none))
            .foregroundStyle(.secondary)
            .redacted(reason: isLoading ? .placeholder : [])
            .contentTransition(.numericText(countsDown: true))
            .animation(.smooth(duration: 0.6), value: displayedCount)
            .onChange(of: count) { _, newValue in
                // Trigger smooth animation when count changes
                withAnimation(.smooth(duration: 0.6)) {
                    displayedCount = newValue
                }
            }
            .onAppear {
                displayedCount = count
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedCountText(count: 42)
        AnimatedCountText(count: nil)
        AnimatedCountText(count: 123, isLoading: true)
    }
    .padding()
}
