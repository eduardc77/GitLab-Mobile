//
//  LinkableTextView.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

/// A SwiftUI view that displays text with automatically clickable links using iOS's native link detection
public struct LinkableTextView: UIViewRepresentable {
    public let text: String

    /// Initialize with text that may contain links
    /// - Parameter text: The text content that may contain URLs
    public init(text: String) {
        self.text = text
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = .link
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = UIColor.label
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .natural
        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        uiView.sizeThatFits(CGSize(width: proposal.width ?? .infinity, height: .infinity))
    }
}

#Preview {
    LinkableTextView(text: "Check out https://github.com/example\n\nThis is a new line with another link: https://gitlab.com")
        .padding()
}
