//
//  ProjectFilesView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabLogging
import GitLabNavigation
import GitLabDesignSystem

/// Repository browser for a project's files.
public struct ProjectFilesView: View {
    public let projectId: Int
    public let repository: any ProjectsRepository
    public let ref: String?
    public let path: String?
    public let router: (any FeatureRouter)?
    public let tab: AppTab

    @State private var items: [ProjectRepositoryItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var didInitialLoad = false
    @State private var isNavigating = false // Prevent rapid successive navigations

    public init(projectId: Int, repository: any ProjectsRepository, ref: String?, path: String? = nil, router: (any FeatureRouter)?, tab: AppTab = .explore) {
        self.projectId = projectId
        self.repository = repository
        self.ref = ref
        self.path = path
        self.router = router
        self.tab = tab
    }

    private func mainListContent() -> some View {
        List(items) { item in
            Button {
                navigateToItem(item)
            } label: {
                HStack {
                    Image(systemName: item.iconName)
                        .foregroundStyle(item.isDirectory ? .blue : .secondary)
                    Text(item.name)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    private var loadingOverlay: some View {
        Group {
            if isLoading {
                LoadingView()
            }
        }
    }

    public var body: some View {
        mainListContent()
            .overlay(loadingOverlay)
            .task {
                guard !didInitialLoad else { return }
                didInitialLoad = true
                await load()
            }
            .navigationTitle(path?.isEmpty == false ? (path ?? "Files") : "Files")
            .alert("Error", isPresented: .init(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: {
                if let message = errorMessage {
                    Text(message)
                } else {
                    Text("Unknown error")
                }
            }

    }

    private func navigateToItem(_ item: ProjectRepositoryItem) {
        guard !isNavigating else { return } // Prevent rapid successive navigations

        if item.isDirectory {
            navigateToDirectory(item.path)
        } else {
            navigateToFile(item.path, blobSHA: item.blobSHA)
        }
    }

    private func navigateToDirectory(_ path: String) {
        guard !isNavigating else { return }
        isNavigating = true

        // Reset navigation flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isNavigating = false
        }

        router?.navigateToProjectFiles(projectId: projectId, ref: ref, path: path)
    }

    private func navigateToFile(_ path: String, blobSHA: String?) {
        guard !isNavigating else { return }
        isNavigating = true

        // Reset navigation flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isNavigating = false
        }

        // Use the correct method for individual file navigation
        router?.navigateToProjectFile(projectId: projectId, path: path, ref: ref, blobSHA: blobSHA)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await repository.repositoryTree(projectId: projectId, path: path, ref: ref)
            AppLog.projects.debug("Loaded tree for projectId=\(projectId), path=\(path ?? "<root>"), count=\(items.count)")
        } catch {
            AppLog.projects.error("Tree load failed for projectId=\(projectId), path=\(path ?? "<root>"): \(String(describing: error))")
            errorMessage = error.localizedDescription
        }
    }
}
