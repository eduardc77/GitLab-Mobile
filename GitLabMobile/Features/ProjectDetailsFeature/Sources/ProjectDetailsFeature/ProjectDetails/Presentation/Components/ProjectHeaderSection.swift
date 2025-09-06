//
//  ProjectHeaderSection.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem
import GitLabNavigation

struct ProjectHeaderSection: View {
    let details: ProjectDetails?
    let router: (any FeatureRouter)?

    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 10) {
                // Large project avatar
                AsyncImageView(url: details?.avatarUrl, targetSize: CGSize(width: 90, height: 90)) {
                    RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemFill))
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                )

                VStack(alignment: .leading) {
                    // Project name
                    Text(details?.name ?? "")
                        .font(.title2)
                        .bold()
                        .lineLimit(2)

                    // Developer/organization name
                    if let namespaceName = details?.namespaceName {
                        Text(namespaceName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()

                    // Action buttons (Share & Star)
                    HStack {
                        // Star button (placeholder for future starring functionality)
                        Button {
                            // TODO: Implement project starring
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "star")
                                Text(String(localized: ProjectDetailsL10n.star))
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.orange)
                        Spacer()

                        // Fork button (placeholder for future forking functionality)
                        Button {
                            // TODO: Implement project forking
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "tuningfork")
                                Text(String(localized: ProjectDetailsL10n.fork))
                            }
                            .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.accentColor)

                    }
                    .accessibilityElement(children: .contain)
                }
            }
        }
        .frame(height: 90)
        .accessibilityLabel(String(localized: ProjectDetailsL10n.sectionOverview))
        .listSectionSeparator(.hidden)
    }
}
