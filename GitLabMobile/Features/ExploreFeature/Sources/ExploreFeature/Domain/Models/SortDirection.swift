//
//  SortDirection.swift
//  ExploreFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import ProjectsDomain

public typealias SortDirection = ProjectsDomain.SortDirection

public extension SortDirection {
    var displayTitle: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}
