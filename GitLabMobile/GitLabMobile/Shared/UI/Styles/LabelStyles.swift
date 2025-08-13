//
//  LabelStyles.swift
//  GitLabMobile
//
//  Created by User on 8/13/25.
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
