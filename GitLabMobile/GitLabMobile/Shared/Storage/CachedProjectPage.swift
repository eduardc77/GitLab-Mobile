//
//  CachedProjectPage.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import SwiftData

@Model
final class CachedProjectPage {
    @Attribute(.unique) var key: String
    var cachedAt: Date
    // Store just ids (encoded as JSON) to preserve ordering; rows live in CachedProject
    // Optional to allow lightweight migration from earlier schema versions
    var projectIdsData: Data?
    // Optional pagination metadata for this page (offset-based)
    var nextPage: Int?

    init(key: String, cachedAt: Date = Date(), projectIdsData: Data?, nextPage: Int?) {
        self.key = key
        self.cachedAt = cachedAt
        self.projectIdsData = projectIdsData
        self.nextPage = nextPage
    }
}
