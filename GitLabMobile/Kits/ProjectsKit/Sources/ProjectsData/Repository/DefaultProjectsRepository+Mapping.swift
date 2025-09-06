//
//  DefaultProjectsRepository+Mapping.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import ProjectsDomain
import GitLabNetwork

extension ProjectSortField {
    var endpointSortBy: ProjectsEndpoints.SortBy {
        switch self {
        case .starCount: return .starCount
        case .lastActivityAt: return .lastActivityAt
        case .createdAt: return .createdAt
        case .name: return .name
        }
    }
}

extension SortDirection {
    var endpointSortDirection: ProjectsEndpoints.SortDirection {
        switch self {
        case .ascending: return .ascending
        case .descending: return .descending
        }
    }
}
