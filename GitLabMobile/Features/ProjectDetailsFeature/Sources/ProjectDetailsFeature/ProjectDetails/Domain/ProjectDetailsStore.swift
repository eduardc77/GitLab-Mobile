//
//  ProjectDetailsStore.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabLogging
import GitLabDesignSystem

@MainActor
@Observable
final class ProjectDetailsStore {
    private(set) var isLoading = false
    private(set) var isLoadingExtras = false
    var errorMessage: String? {
        didSet {
            showErrorAlert = errorMessage != nil
        }
    }
    var showErrorAlert = false

    private(set) var openIssuesCount: Int?
    private(set) var openMergeRequestsCount: Int?
    private(set) var contributorsCount: Int?
    private(set) var releasesCount: Int?
    private(set) var milestonesCount: Int?
    private(set) var commitsCount: Int?
    private(set) var licenseText: String?
    private(set) var licenseType: String?

    var selectedBranch: String? {
        didSet {
            // When branch changes, only refresh commits (branch-specific)
            if oldValue != selectedBranch {
                // Cancel any existing branch task to prevent accumulation
                branchTask?.cancel()

                // Start new task for branch-specific stats only
                branchTask = Task { @MainActor in
                    defer { branchTask = nil }
                    await fetchBranchSpecificStats()
                }
            }
        }
    }

    private(set) var details: ProjectDetails?
    @ObservationIgnored private let repository: any ProjectsRepository
    @ObservationIgnored let projectId: Int

    @ObservationIgnored private var didLoad = false
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var extrasTask: Task<Void, Never>?
    @ObservationIgnored private var branchTask: Task<Void, Never>?
    @ObservationIgnored private var retryCount = 0
    @ObservationIgnored private let maxRetries = 3

    init(projectId: Int, repository: any ProjectsRepository) {
        self.projectId = projectId
        self.repository = repository
    }

    func load() async {
        // Prevent multiple concurrent loads
        guard !didLoad else { return }

        // Cancel any existing load task
        loadTask?.cancel()

        didLoad = true
        isLoading = true
        errorMessage = nil

        loadTask = Task {
            defer {
                isLoading = false
                loadTask = nil
            }

            do {
                details = try await repository.projectDetails(id: projectId)
                await loadAllExtras()
            } catch is CancellationError {
                // User cancelled the operation - reset state
                didLoad = false
                extrasTask?.cancel()
                extrasTask = nil
            } catch {
                didLoad = false // Allow retry on error
                extrasTask?.cancel()
                extrasTask = nil

                // Handle retry logic for network errors
                let classifiedError = classifyError(error)
                if shouldRetry(error: classifiedError) && retryCount < maxRetries {
                    retryCount += 1
                    AppLog.projects.debug("Retrying project details load (attempt \(self.retryCount + 1)) for project \(self.projectId)")

                    // Retry after a delay
                    try? await Task.sleep(nanoseconds: UInt64(retryCount) * 1_000_000_000) // 1 second delay
                    await load() // Recursive retry
                } else {
                    errorMessage = classifiedError.errorDescription
                    retryCount = 0 // Reset retry count on final failure
                }
            }
        }

        await loadTask?.value
    }

    /// Reset the store state to allow reloading
    func reset() {
        loadTask?.cancel()
        extrasTask?.cancel()
        branchTask?.cancel()

        didLoad = false
        isLoading = false
        isLoadingExtras = false
        errorMessage = nil
        details = nil
        openIssuesCount = nil
        openMergeRequestsCount = nil
        contributorsCount = nil
        licenseText = nil
        licenseType = nil
        retryCount = 0 // Reset retry count

        loadTask = nil
        extrasTask = nil
        branchTask = nil
    }

    /// Clear cached project details to force fresh data on next load
    func clearCache() async {
        // Note: The repository handles cache clearing internally
        // This method is for future extensibility if we need manual cache control
        AppLog.projects.debug("Cache clear requested for project \(self.projectId)")
    }

    /// Force refresh project details (bypasses cache)
    func forceRefresh() async {
        do {
            // Use repository's force refresh method (clears cache + fetches fresh)
            details = try await repository.forceRefreshProjectDetails(id: projectId)

            // Reload extras to ensure everything is fresh
            await loadAllExtras()

            AppLog.projects.debug("Force refresh completed for project \(self.projectId)")
        } catch {
            // If force refresh fails, fall back to regular load
            await load()
        }
    }

    /// Determine if an error should trigger a retry
    private func shouldRetry(error: ProjectDetailsError) -> Bool {
        switch error {
        case .networkError, .serverError:
            return true // Retry network and server errors
        case .authenticationError, .notFound, .parsingError, .unknown:
            return false // Don't retry auth, not found, or parsing errors
        }
    }

    deinit {
        loadTask?.cancel()
        extrasTask?.cancel()
        branchTask?.cancel()
    }

    /// Load all extras (stats + license) - convenience method
    func loadAllExtras() async {
        // Cancel any existing extras task
        extrasTask?.cancel()

        isLoadingExtras = true

        // Run extras fetching in background for better UI responsiveness
        extrasTask = Task { @MainActor in
            await self.fetchAllExtras()
            self.isLoadingExtras = false
        }
    }

    /// Load statistics only (issues, MRs, contributors)
    func loadStats() async {
        // Cancel any existing extras task
        extrasTask?.cancel()

        isLoadingExtras = true

        // Run stats fetching in background
        extrasTask = Task { @MainActor in
            await self.fetchStats()
            self.isLoadingExtras = false
        }
    }

    /// Load license only
    func loadLicense() async {
        // Cancel any existing extras task
        extrasTask?.cancel()

        isLoadingExtras = true

        // Run license fetching in background
        extrasTask = Task { @MainActor in
            await self.fetchLicense()
            self.isLoadingExtras = false
        }
    }

    /// Fetch all extras (stats + license)
    private func fetchAllExtras() async {
        // Load stats, license text, and license type in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchStats() }
            group.addTask { await self.fetchLicense() }
            group.addTask { await self.fetchLicenseType() }
        }
    }

    /// Fetch statistics only (issues, MRs, contributors)
    private func fetchStats() async {
        // Use selectedBranch if available, otherwise fallback to details.defaultBranch or "main"
        let branchRef = selectedBranch ?? (details?.defaultBranch ?? "main")

        // Fetch stats in parallel but handle failures individually
        async let issuesTask = repository.openIssuesCount(projectId: self.projectId)
        async let mrsTask = repository.openMergeRequestsCount(projectId: self.projectId)
        async let contributorsTask = repository.contributorsCount(projectId: self.projectId, ref: nil)
        async let releasesTask = repository.releasesCount(projectId: self.projectId)
        async let milestonesTask = repository.milestonesCount(projectId: self.projectId)
        async let commitsTask = repository.commitsCount(projectId: self.projectId, ref: branchRef)

        // Handle each result individually to prevent one failure from affecting others
        do {
            self.openIssuesCount = try await issuesTask
            AppLog.projects.debug("Successfully loaded issues count for project \(self.projectId): \(self.openIssuesCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load issues count for project \(self.projectId): \(error.localizedDescription)")
            self.openIssuesCount = nil
        }

        do {
            self.openMergeRequestsCount = try await mrsTask
            AppLog.projects.debug("Successfully loaded MRs count for project \(self.projectId): \(self.openMergeRequestsCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load MRs count for project \(self.projectId): \(error.localizedDescription)")
            self.openMergeRequestsCount = nil
        }

        do {
            self.contributorsCount = try await contributorsTask
            AppLog.projects.debug("Successfully loaded total contributors count for project \(self.projectId): \(self.contributorsCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load contributors count for project \(self.projectId): \(error.localizedDescription)")
            self.contributorsCount = nil
        }

        do {
            self.releasesCount = try await releasesTask
            AppLog.projects.debug("Successfully loaded releases count for project \(self.projectId): \(self.releasesCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load releases count for project \(self.projectId): \(error.localizedDescription)")
            self.releasesCount = nil
        }

        do {
            self.milestonesCount = try await milestonesTask
            AppLog.projects.debug("Successfully loaded milestones count for project \(self.projectId): \(self.milestonesCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load milestones count for project \(self.projectId): \(error.localizedDescription)")
            self.milestonesCount = nil
        }

        do {
            self.commitsCount = try await commitsTask
            AppLog.projects.debug("Successfully loaded commits count for project \(self.projectId) on branch \(branchRef): \(self.commitsCount ?? 0)")
        } catch {
            AppLog.projects.debug("Failed to load commits count for project \(self.projectId): \(error.localizedDescription)")
            self.commitsCount = nil
        }
    }

    /// Fetch only branch-specific statistics (commits only)
    @MainActor
    private func fetchBranchSpecificStats() async {
        // Use selectedBranch if available, otherwise fallback to details.defaultBranch or "main"
        let branchRef = selectedBranch ?? (details?.defaultBranch ?? "main")

        // Only fetch commits (branch-specific), contributors are project-wide and don't change
        do {
            self.commitsCount = try await repository.commitsCount(projectId: self.projectId, ref: branchRef)
        } catch {
            self.commitsCount = nil
        }
    }

    func selectBranch(_ branchName: String) {
        selectedBranch = branchName
        AppLog.projects.debug("Selected branch: \(branchName) for project \(self.projectId)")
    }

    /// Fetch license only
    private func fetchLicense() async {
        do {
            let licenseData = try await repository.license(projectId: self.projectId)
            self.licenseText = parseLicenseText(from: licenseData)
            AppLog.projects.debug("Successfully loaded license for project \(self.projectId)")
        } catch {
            AppLog.projects.debug("Failed to load license for project \(self.projectId): \(error.localizedDescription)")
            self.licenseText = String(localized: LocalizedStringResource.DesignSystemL10n.none)
        }
    }

    /// Fetch license type only
    private func fetchLicenseType() async {
        self.licenseType = await repository.licenseType(projectId: self.projectId)
        AppLog.projects.debug("Successfully loaded license type for project \(self.projectId): \(self.licenseType ?? "none")")
    }

    /// Classify errors into appropriate categories for user-friendly messaging
    private func classifyError(_ error: Error) -> ProjectDetailsError {
        let description = error.localizedDescription.lowercased()

        // Authentication errors
        if description.contains("unauthorized") ||
            description.contains("401") ||
            description.contains("authentication") {
            return .authenticationError
        }

        // Network errors
        if description.contains("network") ||
            description.contains("connection") ||
            description.contains("timeout") ||
            description.contains("offline") {
            return .networkError(error.localizedDescription)
        }

        // Server errors
        if description.contains("server") ||
            description.contains("5") ||
            description.contains("internal") ||
            description.contains("bad gateway") {
            return .serverError(error.localizedDescription)
        }

        // Not found errors
        if description.contains("not found") ||
            description.contains("404") {
            return .notFound("Project")
        }

        // Parsing/decoding errors
        if description.contains("parsing") ||
            description.contains("decoding") ||
            description.contains("json") {
            return .parsingError(error.localizedDescription)
        }

        // Default to unknown error
        return .unknown(error.localizedDescription)
    }

    private func parseLicenseText(from data: Data) -> String {
        guard !data.isEmpty else {
            return "License unavailable."
        }

        if let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        } else {
            return "License unavailable (invalid encoding)."
        }
    }
}
