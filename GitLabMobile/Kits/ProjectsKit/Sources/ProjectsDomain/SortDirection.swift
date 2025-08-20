//
//  SortDirection.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum SortDirection: String, CaseIterable, Sendable {
    case descending
    case ascending

    public var displayTitle: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}
