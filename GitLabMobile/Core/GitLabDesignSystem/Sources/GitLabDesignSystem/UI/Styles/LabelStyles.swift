//
//  LabelStyles.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct CustomSpacingLabelStyle: LabelStyle {
    public var spacing: CGFloat = 4

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

public extension Label {
    func tightSpacing(_ spacing: CGFloat = 4) -> some View {
        self.labelStyle(CustomSpacingLabelStyle(spacing: spacing))
    }
}
