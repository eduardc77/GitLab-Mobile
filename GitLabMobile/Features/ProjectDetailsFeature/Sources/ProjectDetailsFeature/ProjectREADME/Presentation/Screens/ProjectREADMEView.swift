//
//  ProjectREADMEView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabLogging
import GitLabDesignSystem
import GitLabNetwork
import AuthFeature

public struct ProjectREADMEView: View {
    public let projectId: Int
    public let projectPath: String
    private let store: ProjectREADMEStore

    @Environment(AuthenticationStore.self) private var authStore
    @Environment(\.imageLoader) private var imageLoader

    private var linkHandler: READMELinkHandler {
        READMELinkHandler(projectPath: projectPath, projectId: projectId)
    }

    public init(
        projectId: Int,
        projectPath: String,
        repository: any ProjectsRepository
    ) {
        self.projectId = projectId
        self.projectPath = projectPath
        self.store = ProjectREADMEStore(projectId: projectId, repository: repository)
    }

    public var body: some View {
        Group {
            switch store.state {
            case .idle:
                emptyView
            case .loading:
                loadingView
            case .loaded(let readme):
                readmeContentView(readme)
            case .error(let message):
                errorView(error: message)
            }
        }
        .navigationTitle("README")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // First update auth token, then load README
            await updateAuthToken()

            // Only load initially if we haven't loaded before
            guard !store.hasLoadedInitially else { return }
            await store.load()
        }
    }
    // MARK: - Loading View
    @ViewBuilder
    private var loadingView: some View {
        LoadingView()
    }

    // MARK: - Error View
    @ViewBuilder
    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Unable to Load README")
                .font(.headline)

            Text(error)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Empty View
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No README Found")
                .font(.headline)

            Text("This project doesn't have a README file.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - README Content View
    @ViewBuilder
    private func readmeContentView(_ readme: ProjectREADME) -> some View {
            READMEWebView(
                htmlContent: readme.renderedHTML,
                baseURL: createBaseURL(for: readme),
                projectId: readme.projectId,
                onLinkTap: handleLinkTap,
                scrollToAnchor: store.scrollToAnchor,
                authToken: store.secureAuthToken
            )
    }

    // MARK: - Helper Methods
    private func createBaseURL(for readme: ProjectREADME) -> URL? {
        // Use GitLab's web interface URL for proper HTML rendering
        // GitLab's rendered HTML expects web URLs, not API URLs
        do {
            let config = try AppNetworkingConfig.loadFromInfoPlist()

            var components = URLComponents()
            components.scheme = config.baseURL.scheme
            components.host = config.baseURL.host
            components.port = config.baseURL.port
            components.path = "/projects/\(readme.projectId)/-/raw/\(readme.ref)"

            return components.url
        } catch {
            AppLog.projects.error("Failed to create authenticated base URL for README: \(error.localizedDescription)")
            // Fallback to web URL
            var components = URLComponents()
            components.scheme = "https"
            components.host = "gitlab.com"
            components.path = "/project/\(readme.projectId)/-/raw/\(readme.ref)"
            return components.url
        }
    }

    private func handleLinkTap(_ url: URL) -> Bool {
        let action = linkHandler.handleLink(url)

        switch action {
        case .scrollToAnchor(let anchor):
            store.setScrollAnchor(anchor)
            return true

        case .navigateToProjectFile(let filePath):
            // TODO: Implement navigation to file viewer for same project
            AppLog.projects.info("Navigation to project file requested: \(filePath)")
            return true

        case .openExternally:
            return false // Let system handle external URLs
        case .ignore:
            return true // Link was handled by choosing to ignore it
        }
    }

    private func updateAuthToken() async {
        do {
            let token = try await authStore.getValidToken()
            store.secureAuthToken = token.accessToken
            AppLog.projects.debug("READMEWebView: Successfully obtained auth token for project \(projectId)")
        } catch {
            AppLog.projects.error("READMEWebView: Failed to get auth token for project \(projectId): \(error.localizedDescription)")
            store.secureAuthToken = nil
        }
    }
}
