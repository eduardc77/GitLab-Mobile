//
//  DefaultProjectsRepository.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabUtilities
import ProjectsCache
import GitLabNetwork
import GitLabLogging

// Import for NetworkError handling
public typealias NetworkError = GitLabNetwork.NetworkError

public actor DefaultProjectsRepository: ProjectsRepository {
    let remote: ProjectsRemoteDataSource
    let local: ProjectsLocalDataSource
    let projectDetailsLocal: ProjectDetailsLocalDataSource
    let staleness: TimeInterval
    private let perPageDefault: Int
    private let readmeService: READMEService

    public init(
        remote: ProjectsRemoteDataSource,
        local: ProjectsLocalDataSource,
        projectDetailsLocal: ProjectDetailsLocalDataSource,
        readmeService: READMEService,
        staleness: TimeInterval = StoreDefaults.cacheStaleInterval,
        perPageDefault: Int = StoreDefaults.perPage
    ) {
        self.remote = remote
        self.local = local
        self.projectDetailsLocal = projectDetailsLocal
        self.readmeService = readmeService
        self.staleness = staleness
        self.perPageDefault = perPageDefault
    }

    public func configureLocalCache(makeCache: @escaping @Sendable @MainActor () -> ProjectsCacheProviding) async {
        await local.configure(makeCache: makeCache)

        // Configure project details cache
        await projectDetailsLocal.configure(makeCache: { () -> ProjectDetailsCacheProviding in
            // Cast to the combined protocol since ProjectsCache implements both
            if let cache = makeCache() as? ProjectDetailsCacheProviding {
                return cache
            }
            // Fallback - this shouldn't happen with our current implementation
            fatalError("Cache does not support project details")
        })
    }

    public func projectDetails(id: Int) async throws -> ProjectDetails {
        // Try to load from cache first (for offline support)
        if let cachedDTO = await projectDetailsLocal.loadProjectDetails(id: id, staleInterval: staleness) {
            let projectDetails = ProjectDetails(from: cachedDTO)
            AppLog.projects.debug("✅ Project details \(id) loaded from cache - offline ready!")

            // Background refresh (don't await)
            Task {
                await refreshProjectDetails(id: id)
            }

            return projectDetails
        }

        // No cache available, fetch from network
        AppLog.projects.debug("🌐 Project details \(id) not cached - fetching from network")
        return try await fetchAndCacheProjectDetails(id: id)
    }

    private func fetchAndCacheProjectDetails(id: Int) async throws -> ProjectDetails {
        let dto = try await remote.fetchProjectDetails(id: id)
        let projectDetails = ProjectDetails(
            id: dto.id,
            name: dto.name,
            pathWithNamespace: dto.pathWithNamespace,
            namespaceName: dto.namespace?.name,
            description: dto.description,
            starCount: dto.starCount ?? 0,
            forksCount: dto.forksCount ?? 0,
            avatarUrl: dto.avatarUrl.flatMap(URL.init),
            webUrl: URL(string: dto.webUrl) ?? URL(string: "https://gitlab.com/project/\(dto.id)") ?? URL(fileURLWithPath: "/"),
            createdAt: dto.createdAt,
            lastActivityAt: dto.lastActivityAt,
            defaultBranch: dto.defaultBranch,
            visibility: dto.visibility,
            topics: dto.topics ?? []
        )

        // Cache the fresh data
        await projectDetailsLocal.saveProjectDetails(projectDetails)
        AppLog.projects.debug("💾 Project details \(id) cached successfully")

        return projectDetails
    }

    private func refreshProjectDetails(id: Int) async {
        AppLog.projects.debug("🔄 Background refresh started for project \(id)")
        do {
            // This will update cache if data has changed (ETag prevents unnecessary downloads)
            _ = try await fetchAndCacheProjectDetails(id: id)
            AppLog.projects.debug("🔄 Background refresh completed for project \(id)")
        } catch let error as NetworkError {
            if case .server(304, _) = error {
                // Data hasn't changed - this is expected and good!
                AppLog.projects.debug("🔄 Project details \(id) unchanged (304), cache remains valid")
            } else {
                // Other NetworkError cases - cache remains unchanged
                AppLog.projects.debug("🔄 Failed to refresh project details \(id): \(error.localizedDescription)")
            }
        } catch {
            // Other errors (offline, auth, etc.) - cache remains unchanged
            AppLog.projects.debug("🔄 Failed to refresh project details \(id): \(error.localizedDescription)")
        }
    }

    /// Force refresh project details by clearing cache first
    public func forceRefreshProjectDetails(id: Int) async throws -> ProjectDetails {
        // Clear cache first to force fresh data
        AppLog.projects.debug("🗑️ Force clearing cache for project \(id)")
        await projectDetailsLocal.clearProjectDetails(id: id)

        // Fetch fresh data (will recache automatically)
        AppLog.projects.debug("🔄 Force refresh started for project \(id)")
        return try await fetchAndCacheProjectDetails(id: id)
    }

    // MARK: - Extra fetchers (issues/MRs counts, license, tree)

    public func openIssuesCount(projectId: Int) async throws -> Int {
        try await remote.fetchIssuesOpenCount(projectId: projectId)
    }

    public func openMergeRequestsCount(projectId: Int) async throws -> Int {
        let page: Paginated<[MRCountProbeDTO]> = try await remote.fetchMergeRequestsOpenCount(
            projectId: projectId,
            state: "opened"
        )
        return page.pageInfo?.total ?? 0
    }

    public func contributorsCount(projectId: Int, ref: String?) async throws -> Int {
        try await remote.fetchContributorsCount(projectId: projectId, ref: ref)
    }

    public func releasesCount(projectId: Int) async throws -> Int {
        try await remote.fetchReleasesCount(projectId: projectId)
    }

    public func milestonesCount(projectId: Int) async throws -> Int {
        try await remote.fetchMilestonesCount(projectId: projectId)
    }

    public func commitsCount(projectId: Int, ref: String?) async throws -> Int {
        try await remote.fetchCommitsCount(projectId: projectId, ref: ref)
    }

    public func branches(projectId: Int) async throws -> [Branch] {
        let dtos = try await remote.fetchBranches(projectId: projectId)
        return dtos.map { Branch(
            id: $0.name,
            name: $0.name,
            commit: $0.commit.map { BranchCommit(
                id: $0.id ?? "",
                shortId: $0.shortId ?? "",
                title: $0.title ?? "",
                authorName: $0.authorName ?? "",
                authoredDate: $0.authoredDate ?? Date()
            )},
            isProtected: $0.isProtected,
            isDefault: $0.isDefault
        )}
    }

    public func repositoryTree(projectId: Int, path: String?, ref: String?) async throws -> [ProjectRepositoryItem] {
        let dtos = try await remote.fetchRepositoryTree(projectId: projectId, path: path, ref: ref)
        return dtos.map { ProjectRepositoryItem(name: $0.name, path: $0.path, isDirectory: $0.type == "tree", blobSHA: $0.id) }
    }

    public func rawFile(projectId: Int, path: String, ref: String?) async throws -> Data {
        let effectiveRef: String?
        if let ref, !ref.isEmpty {
            effectiveRef = ref
        } else {
            effectiveRef = try await remote.fetchDefaultBranch(projectId: projectId)
        }
        return try await remote.fetchRawFile(projectId: projectId, path: path, ref: effectiveRef)
    }

    public func rawFileURL(projectId: Int, path: String, ref: String?, networkingConfig: NetworkingConfig) async throws -> URL {
        let effectiveRef: String?
        if let ref, !ref.isEmpty {
            effectiveRef = ref
        } else {
            effectiveRef = try await remote.fetchDefaultBranch(projectId: projectId)
        }

        // Encode path components safely (same as ProjectsEndpoints.rawFile)
        let encodedPath: String = path
            .split(separator: "/", omittingEmptySubsequences: false)
            .map { component -> String in
                var allowed = CharacterSet.urlPathAllowed
                allowed.remove(charactersIn: "/")
                let raw = String(component)
                let enc = raw.addingPercentEncoding(withAllowedCharacters: allowed) ?? raw
                return enc.replacingOccurrences(of: ".", with: "%2E")
            }
            .joined(separator: "%2F")

        // Build the full path for the API endpoint
        let basePath = networkingConfig.baseURL.path.isEmpty ? "" : networkingConfig.baseURL.path
        let fullPath = basePath + networkingConfig.apiPrefix + "/projects/\(projectId)/repository/files/\(encodedPath)/raw"

        var components = URLComponents()
        components.scheme = networkingConfig.baseURL.scheme
        components.host = networkingConfig.baseURL.host
        components.port = networkingConfig.baseURL.port
        components.percentEncodedPath = fullPath

        if let effectiveRef, !effectiveRef.isEmpty {
            components.queryItems = [URLQueryItem(name: "ref", value: effectiveRef)]
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return url
    }

    public func rawBlob(projectId: Int, sha: String) async throws -> Data {
        try await remote.fetchRawBlob(projectId: projectId, sha: sha)
    }

    public func projectREADME(projectId: Int, ref: String?) async throws -> ProjectREADME {
        AppLog.projects.debug("Repository: Fetching README for project \(projectId), ref: \(ref ?? "default")")
        let readme = try await readmeService.fetchREADME(for: projectId, ref: ref)
        AppLog.projects.debug("Repository: Successfully fetched README with \(readme.renderedHTML.count) characters of HTML")
        return readme
    }
}
