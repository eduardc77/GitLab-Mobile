//
//  ProjectSortField.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

public enum ProjectSortField: String, CaseIterable {
    case starCount
    case lastActivityAt
    case createdAt
    case name

    var displayTitle: String {
        switch self {
        case .starCount: return "Stars"
        case .lastActivityAt: return "Updated date"
        case .createdAt: return "Created date"
        case .name: return "Name"
        }
    }
}
