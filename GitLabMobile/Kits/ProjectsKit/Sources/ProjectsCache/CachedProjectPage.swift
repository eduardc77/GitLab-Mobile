//
//  CachedProjectPage.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import SwiftData

@Model
public final class CachedProjectPage {
    @Attribute(.unique) public var key: String
    public var cachedAt: Date
    // Store just ids (encoded as JSON) to preserve ordering; rows live in CachedProject
    // Optional to allow lightweight migration from earlier schema versions
    public var projectIdsData: Data?
    // Optional pagination metadata for this page (offset-based)
    public var nextPage: Int?

    public init(key: String, cachedAt: Date = Date(), projectIdsData: Data?, nextPage: Int?) {
        self.key = key
        self.cachedAt = cachedAt
        self.projectIdsData = projectIdsData
        self.nextPage = nextPage
    }
}
