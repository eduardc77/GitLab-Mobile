//
//  ProjectDetailsView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import AuthFeature
import ProjectsDomain
import GitLabDesignSystem
import GitLabNavigation
import GitLabLogging

public struct ProjectDetailsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(AuthenticationStore.self) private var authStore
    @State private var store: ProjectDetailsStore
    @State private var showingBranchSelection = false
    private let router: (any FeatureRouter)?
    private let repository: any ProjectsRepository

    public init(
        projectId: Int,
        repository: any ProjectsRepository,
        router: (any FeatureRouter)?,
        tab: AppTab
    ) {
        // Input validation
        precondition(projectId > 0, "Project ID must be positive")
        precondition(tab != .notifications, "Project details not supported in notifications tab")

        self.repository = repository
        self.router = router
        self.store = ProjectDetailsStore(projectId: projectId, repository: repository)
    }

    public var body: some View {
        List {
            headerSection
            if let details = store.details {
                metaInformationSection(for: details)
                descriptionAndTopicsSection
            }
            activitySection
            repositorySection
            if authStore.status == .authenticated, let details = store.details {
                readmeNavigationLink(for: details)
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await refreshProjectDetails()
        }
        .task {
            await store.load()
            await authStore.restoreIfPossible()
        }
        .overlay {
            if store.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $showingBranchSelection) {
            if let details = store.details {
                BranchSelectionView(
                    projectId: details.id,
                    repository: repository,
                    currentBranch: store.selectedBranch ?? details.defaultBranch,
                    onBranchSelected: { branchName in
                        store.selectBranch(branchName)
                        showingBranchSelection = false
                    }
                )
            }
        }
        .alert(
            String(localized: ProjectDetailsL10n.error),
            isPresented: $store.showErrorAlert,
            presenting: store.errorMessage
        ) { _ in
            Button(String(localized: ProjectDetailsL10n.okButtonTitle), role: .cancel) {}
            Button(String(localized: ProjectDetailsL10n.retryButtonTitle)) {
                Task { await store.load() }
            }
        } message: { errorMessage in
            Text(errorMessage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let url = store.details?.webUrl {
                    Menu {
                        Button {
                            openURL(url)
                        } label: {
                            Label(String(localized: ProjectDetailsL10n.openInBrowser), systemImage: "safari")
                        }

                        ShareLink(item: url) {
                            Label(String(localized: ProjectDetailsL10n.shareProject), systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel(String(localized: ProjectDetailsL10n.moreActions))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(store.details.map { "Project details for \($0.name)" } ?? "Loading project details")

    }

    private var activitySection: some View {
        ActivitySection(
            openIssuesCount: store.openIssuesCount,
            openMergeRequestsCount: store.openMergeRequestsCount,
            contributorsCount: store.contributorsCount,
            releasesCount: store.releasesCount,
            milestonesCount: store.milestonesCount,
            isLoadingExtras: store.isLoadingExtras,
            licenseType: store.licenseType,
            isLoadingLicense: store.isLoadingExtras,
            details: store.details,
            router: router
        )
    }

    private var repositorySection: some View {
        RepositorySection(
            details: store.details,
            selectedBranch: store.selectedBranch,
            commitsCount: store.commitsCount,
            isLoadingExtras: store.isLoadingExtras,
            router: router,
            onBranchSelectionRequested: {
                showingBranchSelection = true
            }
        )
    }

    private func readmeNavigationLink(for details: ProjectDetails) -> some View {
        Button {
            router?.navigateToProjectReadme(projectId: details.id, projectPath: details.pathWithNamespace)
        } label: {
            HStack {
                Label {
                    Text(String(localized: ProjectDetailsL10n.openReadme))
                } icon: {
                    Image(systemName: "richtext.page")
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
        .buttonStyle(.plain)
    }

    // MARK: - Header & Meta

    private var headerSection: some View {
        ProjectHeaderSection(details: store.details, router: router)
    }

    private func metaInformationSection(for details: ProjectDetails) -> some View {
        MetaInformationSection(details: details)
    }

    private var descriptionAndTopicsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                if let details = store.details {
                    if let description = details.description, !description.isEmpty {
                        projectDescriptionView(description)
                    }
                    if !details.topics.isEmpty {
                        topicsView(details.topics)
                    }
                }
            }
        }
    }

    private func projectDescriptionView(_ description: String) -> some View {
        LinkableTextView(text: description)
            .multilineTextAlignment(.leading)
    }

    private func topicsView(_ topics: [String]) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(topics, id: \.self) { topic in
                    Text(topic)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(.secondarySystemFill)))
                        .foregroundStyle(.secondary)
                }
            }
            .scrollTargetLayout()
        }
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
            .accessibilityLabel(String(localized: ProjectDetailsL10n.topics))
    }

    /// Handle pull-to-refresh by force refreshing all project data
    @MainActor
    private func refreshProjectDetails() async {
        // Force refresh to bypass cache and get latest data
        await store.forceRefresh()

        // Log successful refresh
        AppLog.projects.debug("Project \(store.projectId) force refreshed via pull-to-refresh")
    }
}
