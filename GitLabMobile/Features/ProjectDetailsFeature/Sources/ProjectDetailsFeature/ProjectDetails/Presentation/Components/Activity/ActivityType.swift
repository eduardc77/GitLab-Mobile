//
//  ActivityType.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

/// Enum representing all activity types with their metadata
enum ActivityType: CaseIterable {
    case openIssues
    case openMRs
    case contributors
    case releases
    case milestones

    var title: String {
        switch self {
        case .openIssues: return String(localized: ProjectDetailsL10n.openIssues)
        case .openMRs: return String(localized: ProjectDetailsL10n.openMRs)
        case .contributors: return String(localized: ProjectDetailsL10n.contributors)
        case .releases: return String(localized: ProjectDetailsL10n.releases)
        case .milestones: return String(localized: ProjectDetailsL10n.milestones)
        }
    }

    var iconName: String {
        switch self {
        case .openIssues: return "exclamationmark.circle"
        case .openMRs: return "arrow.triangle.merge"
        case .contributors: return "person.2"
        case .releases: return "tag"
        case .milestones: return "flag"
        }
    }
}
