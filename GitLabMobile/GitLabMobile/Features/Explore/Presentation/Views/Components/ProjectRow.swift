//
//  ProjectRow.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

struct ProjectRow: View {
    let project: ProjectSummary

    var body: some View {
        HStack {
            AvatarView(url: project.avatarUrl)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .lineLimit(1)

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
                        Text("Updated \(date, format: .relative(presentation: .named))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.secondary)
            }
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
        .frame(width: 40, height: 40)
        .clipShape(.rect(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}
