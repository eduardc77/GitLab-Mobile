//
//  ProjectRow.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem

public struct ProjectRow: View {
    public let project: ProjectSummary

    public init(project: ProjectSummary) {
        self.project = project
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                AvatarView(url: project.avatarUrl)

                VStack(alignment: .leading) {
                    Text(project.name)
                        .font(.headline)
                        .lineLimit(1)

                    if let namespaceName = project.namespaceName {
                        Text(namespaceName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            if let description = project.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                HStack {
                    Text("\(project.starCount)")
                    Image(systemName: "star")
                }
                .font(.caption2)

                HStack {
                    Text("\(project.forksCount)")
                    Image(systemName: "arrow.branch")
                }
                .font(.caption2)

                Spacer()

                if let date = project.lastActivityAt {
                    let relative = date.formatted(.relative(presentation: .named))
                    let format = String(localized: .DesignSystemL10n.updated)
                    Text(String(format: format, relative))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.secondary)
        }
    }
}

private struct AvatarView: View {
    let url: URL?

    var body: some View {
        AsyncImageView(
            url: url,
            contentMode: .fill,
            targetSize: CGSize(width: 40, height: 40)
        ) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemFill))
                .overlay(Image(systemName: "folder").imageScale(.small).foregroundStyle(.secondary))
        }
        .clipShape(.rect(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
}
