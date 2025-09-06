//
//  ProjectsEndpoints.swift
//  GitLabNetwork
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum ProjectsEndpoints {

    public enum SortBy: String, CaseIterable, Sendable {
        case starCount = "star_count"
        case lastActivityAt = "last_activity_at"
        case createdAt = "created_at"
        case name = "name"
    }

    // Raw blob by SHA (no ref required)
    public static func rawBlob(projectId: Int, sha: String) -> Endpoint<Data> {
        Endpoint<Data>(
            path: "/projects/\(projectId)/repository/blobs/\(sha)/raw",
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true)
        )
    }

    public enum SortDirection: String, CaseIterable, Sendable {
        case descending = "desc"
        case ascending = "asc"
    }

    // Authenticated
    public static func owned(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "owned", value: "true"),
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func starred(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "starred", value: "true"),
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func membership(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "membership", value: "true"),
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func contributed(page: Int = 1, perPage: Int = 20, search: String? = nil) -> Endpoint<[ProjectDTO]> {
        Endpoint(
            path: "/projects",
            queryItems: [
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "with_programming_language", value: "true"),
                // placeholder param; adjust to real contributed filter if available
                .init(name: "min_access_level", value: "10"),
                // ensures user-visible contributions; server-side supported filters may vary
            ].appendingSearch(search),
            options: RequestOptions(cachePolicy: nil, timeout: nil, useETag: true)
        )
    }

    public static func project(id: Int) -> Endpoint<ProjectDTO> {
        Endpoint(
            path: "/projects/\(id)",
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: true)
        )
    }

    // Issues statistics (open/closed counts)
    public static func issuesStatistics(projectId: Int) -> Endpoint<IssuesStatisticsDTO> {
        Endpoint(
            path: "/projects/\(projectId)/issues_statistics",
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: false)
        )
    }

    // Repository statistics (commit counts, etc.)
    public static func repositoryStatistics(projectId: Int) -> Endpoint<RepositoryStatisticsDTO> {
        Endpoint(
            path: "/projects/\(projectId)/statistics",
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: false)
        )
    }

    // Merge requests count via list head page headers (X-Total) for open MRs
    public static func mergeRequestsCount(projectId: Int, state: String = "opened") -> Endpoint<[MRCountProbeDTO]> {
        Endpoint(
            path: "/projects/\(projectId)/merge_requests",
            queryItems: [
                .init(name: "per_page", value: "1"), // Minimal pagination - 1 item to get total count
                .init(name: "state", value: state),
            ],
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: false)
        )
    }

    public static func list(
        orderBy: SortBy,
        sort: SortDirection,
        page: Int = 1,
        perPage: Int = 20,
        search: String? = nil,
        publicOnly: Bool = true
    ) -> Endpoint<[ProjectDTO]> {
        var items: [URLQueryItem] = [
            .init(name: "page", value: String(page)),
            .init(name: "per_page", value: String(perPage)),
            .init(name: "order_by", value: orderBy.rawValue),
            .init(name: "sort", value: sort.rawValue),
        ]
        if publicOnly { items.append(.init(name: "visibility", value: "public")) }
        if publicOnly { items.append(.init(name: "simple", value: "true")) }
        items = items.appendingSearch(search)
        return Endpoint(
            path: "/projects",
            queryItems: items,
            options: RequestOptions(
                cachePolicy: nil,
                timeout: 8,
                useETag: true,
                attachAuthorization: false
            )
        )
    }

    // Repository tree (files and folders)
    public static func repositoryTree(projectId: Int, path: String? = nil, ref: String? = nil, perPage: Int = 100, recursive: Bool = false) -> Endpoint<[RepositoryTreeItemDTO]> {
        var items: [URLQueryItem] = [
            .init(name: "per_page", value: String(perPage)),
            .init(name: "recursive", value: recursive ? "true" : "false"),
        ]
        if let path, !path.isEmpty { items.append(.init(name: "path", value: path)) }
        if let ref, !ref.isEmpty { items.append(.init(name: "ref", value: ref)) }
        return Endpoint(
            path: "/projects/\(projectId)/repository/tree",
            queryItems: items,
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true)
        )
    }

    // Contributors
    public static func contributors(projectId: Int, page: Int = 1, perPage: Int = 20, ref: String? = nil) -> Endpoint<[ContributorsDTO]> {
        var items: [URLQueryItem] = [
            .init(name: "page", value: String(page)),
            .init(name: "per_page", value: String(perPage)),
        ]
        if let ref, !ref.isEmpty { items.append(.init(name: "ref", value: ref)) }
        return Endpoint(
            path: "/projects/\(projectId)/repository/contributors",
            queryItems: items,
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: false)
        )
    }

    // Raw file
    public static func rawFile(projectId: Int, path: String, ref: String?) -> Endpoint<Data> {
        var items: [URLQueryItem] = []
        if let ref, !ref.isEmpty { items.append(.init(name: "ref", value: ref)) }
        // Per GitLab docs the file_path must be URL-encoded with slashes as %2F and dots as %2E.
        // Build it by encoding each component then joining with %2F to avoid double-encoding.
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
        return Endpoint<Data>(
            path: "/projects/\(projectId)/repository/files/\(encodedPath)/raw",
            queryItems: items,
            options: RequestOptions(cachePolicy: nil, timeout: 8, useETag: true, attachAuthorization: true)
        )
    }

    public static func releases(projectId: Int, page: Int = 1, perPage: Int = 20) -> Endpoint<[ReleaseDTO]> {
        Endpoint<[ReleaseDTO]>(
            path: "/projects/\(projectId)/releases",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
            ]
        )
    }

    public static func milestones(projectId: Int, page: Int = 1, perPage: Int = 20) -> Endpoint<[MilestoneDTO]> {
        Endpoint<[MilestoneDTO]>(
            path: "/projects/\(projectId)/milestones",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
            ]
        )
    }

    public static func commits(projectId: Int, ref: String?, page: Int = 1, perPage: Int = 20) -> Endpoint<[CommitDTO]> {
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        if let ref, !ref.isEmpty {
            queryItems.append(URLQueryItem(name: "ref", value: ref))
        }
        return Endpoint<[CommitDTO]>(
            path: "/projects/\(projectId)/repository/commits",
            queryItems: queryItems
        )
    }

    // Sequence endpoint for exact commit count (GitLab >= 16.9)
    public static func commitSequence(projectId: Int, sha: String) -> Endpoint<CommitSequenceDTO> {
        Endpoint<CommitSequenceDTO>(
            path: "/projects/\(projectId)/repository/commits/\(sha)/sequence"
        )
    }

    public static func branches(projectId: Int) -> Endpoint<[BranchDTO]> {
        Endpoint<[BranchDTO]>(
            path: "/projects/\(projectId)/repository/branches"
        )
    }
}

private extension Array where Element == URLQueryItem {
    func appendingSearch(_ query: String?) -> [URLQueryItem] {
        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return self }
        var copy = self
        copy.append(URLQueryItem(name: "search", value: query))
        return copy
    }

    // No cursor param in offset pagination
}
