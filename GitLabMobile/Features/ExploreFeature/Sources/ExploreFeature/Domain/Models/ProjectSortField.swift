//
//  ProjectSortField.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import ProjectsDomain

public typealias ProjectSortField = ProjectsDomain.ProjectSortField

public extension ProjectSortField {
    var displayTitle: String {
        switch self {
        case .starCount: return "Stars"
        case .lastActivityAt: return "Updated date"
        case .createdAt: return "Created date"
        case .name: return "Name"
        }
    }
}
