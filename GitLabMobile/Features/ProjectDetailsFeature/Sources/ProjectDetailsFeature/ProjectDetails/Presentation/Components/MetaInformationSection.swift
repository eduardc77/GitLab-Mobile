//
//  MetaInformationSection.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem

struct MetaInformationSection: View {
    let details: ProjectDetails

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                Divider()
                HStack {
                    ForEach(MetaItemType.allCases.filter { $0.shouldShow(for: details) }, id: \.self) { itemType in
                        if let value = itemType.value(from: details) {
                            metaItem(
                                icon: itemType.icon,
                                value: value,
                                label: String(localized: itemType.labelKey)
                            )
                        }
                        if itemType != MetaItemType.allCases.filter({ $0.shouldShow(for: details) }).last {
                            Divider()
                                .padding(.vertical)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
        }
    }

    // Helper function for horizontal meta items
    private func metaItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.footnote)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
        }
        .frame(minWidth: 60)
        .foregroundStyle(.secondary)
    }
}
