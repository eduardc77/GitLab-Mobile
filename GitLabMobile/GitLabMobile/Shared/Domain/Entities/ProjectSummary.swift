//
//  ProjectSummary.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ProjectSummary: Identifiable, Decodable, Equatable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let pathWithNamespace: String
    public let description: String?
    public let starCount: Int
    public let forksCount: Int
    public let avatarUrl: URL?
    public let webUrl: URL
    public let lastActivityAt: Date?
}
