//
//  ProjectDetailsView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem

public struct ProjectDetailsView: View {
    @State private var store: ProjectDetailsStore

    public init(projectId: Int, repository: any ProjectsRepository) {
        _store = State(initialValue: ProjectDetailsStore(projectId: projectId, repository: repository))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                meta
                if let topics = store.details?.topics, topics.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(topics, id: \.self) { topic in
                                Text(topic)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color(.secondarySystemFill)))
                            }
                        }
                    }
                }
                if let description = store.details?.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(store.details?.name ?? "")
        .task { await store.load() }
        .overlay {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
        .alert(String(localized: .ProjectDetailsL10n.error), isPresented: Binding(
            get: { (store.errorMessage ?? "").isEmpty == false },
            set: { _ in store.errorMessage = nil }
        )) {
            Button(String(localized: .ProjectDetailsL10n.okButtonTitle), role: .cancel) {}
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    @ViewBuilder private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImageView(url: store.details?.avatarUrl) {
                RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemFill))
            }
            .frame(width: 56, height: 56)
            .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(store.details?.name ?? "")
                    .font(.title3).bold()
                    .lineLimit(2)
                if let path = store.details?.pathWithNamespace {
                    Text(path)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder private var meta: some View {
        HStack(spacing: 16) {
            if let stars = store.details?.starCount {
                Label("\(stars)", systemImage: "star").font(.footnote)
            }
            if let forks = store.details?.forksCount {
                Label("\(forks)", systemImage: "arrow.branch").font(.footnote)
            }
            if let branch = store.details?.defaultBranch, !branch.isEmpty {
                Label(branch, systemImage: "arrow.triangle.branch").font(.footnote)
            }
            if let visibility = store.details?.visibility, !visibility.isEmpty {
                Label(visibility.capitalized, systemImage: "eye").font(.footnote)
            }
            if let date = store.details?.lastActivityAt {
                let relative = date.formatted(.relative(presentation: .named))
                let format = String(localized: .DesignSystem.updated)
                Text(String(format: format, relative)).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.secondary)
    }
}


