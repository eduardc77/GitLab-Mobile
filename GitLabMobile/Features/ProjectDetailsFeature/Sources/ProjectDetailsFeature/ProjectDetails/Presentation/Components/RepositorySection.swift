//
//  RepositorySection.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem
import GitLabNavigation

struct RepositorySection: View {
    let details: ProjectDetails?
    let selectedBranch: String?
    let commitsCount: Int?
    let isLoadingExtras: Bool
    let router: (any FeatureRouter)?
    let onBranchSelectionRequested: () -> Void

    var body: some View {
        if let details = details {
            Section {
                filesSectionContent(for: details)
                commitsSectionContent
            } header: {
                HStack {
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                        Text(selectedBranch ?? details.defaultBranch ?? "master")
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Button(String(localized: ProjectDetailsL10n.changeBranch)) {
                        onBranchSelectionRequested()
                    }
                    .foregroundStyle(.tint)
                }
                .font(.subheadline)
            }
            .accessibilityLabel(String(localized: ProjectDetailsL10n.repositoryBranch))
        }
    }

    private func filesSectionContent(for details: ProjectDetails) -> some View {
        Button {
            router?.navigateToProjectFiles(projectId: details.id, ref: selectedBranch ?? details.defaultBranch ?? "main", path: nil)
        } label: {
            filesLinkContent
        }
        .buttonStyle(.plain)
    }

    private var filesLinkContent: some View {
        HStack {
            Label {
                Text(String(localized: ProjectDetailsL10n.browseFiles))
            } icon: {
                Image(systemName: "folder")
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }

    private var commitsSectionContent: some View {
        HStack {
            Label {
                Text(String(localized: ProjectDetailsL10n.commits))
            } icon: {
                Image(systemName: "circle.and.line.horizontal")
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Text(commitsCount.map { "\($0)" } ?? String(localized: ProjectDetailsL10n.none))
                .foregroundStyle(.secondary)
                .redacted(reason: isLoadingExtras && commitsCount == nil ? .placeholder : [])
        }
    }
}
