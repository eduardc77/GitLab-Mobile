//
//  ProjectRowItem.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public struct ProjectRowItem: Identifiable, Sendable, Equatable {
    public let id: Int
    public let title: String
    public let subtitle: String
    public let starsText: String
    public let avatarURL: URL?

    public init(from domain: ProjectSummary) {
        self.id = domain.id
        self.title = domain.name
        self.subtitle = domain.pathWithNamespace
        self.starsText = "\(domain.starCount)"
        self.avatarURL = domain.avatarUrl
    }
}
