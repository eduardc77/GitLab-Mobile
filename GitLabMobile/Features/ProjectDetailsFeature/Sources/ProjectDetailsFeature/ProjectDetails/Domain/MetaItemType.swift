//
//  MetaItemType.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain

enum MetaItemType: CaseIterable {
    case stars
    case forks
    case branch
    case visibility
    case updated
    case created

    var icon: String {
        switch self {
        case .stars: return "star"
        case .forks: return "tuningfork"
        case .branch: return "arrow.triangle.pull"
        case .visibility: return "eye"
        case .updated: return "clock"
        case .created: return "calendar"
        }
    }

    var labelKey: LocalizedStringResource {
        switch self {
        case .stars: return ProjectDetailsL10n.metaStars
        case .forks: return ProjectDetailsL10n.metaForks
        case .branch: return ProjectDetailsL10n.metaBranch
        case .visibility: return ProjectDetailsL10n.metaVisibility
        case .updated: return ProjectDetailsL10n.metaUpdated
        case .created: return ProjectDetailsL10n.metaCreated
        }
    }

    func value(from details: ProjectDetails) -> String? {
        switch self {
        case .stars: return "\(details.starCount)"
        case .forks: return "\(details.forksCount)"
        case .branch: return details.defaultBranch
        case .visibility: return details.visibility?.capitalized
        case .updated: return details.lastActivityAt?.formatted(.relative(presentation: .named))
        case .created: return details.createdAt?.formatted(.relative(presentation: .named))
        }
    }

    func shouldShow(for details: ProjectDetails) -> Bool {
        switch self {
        case .stars, .forks: return true
        case .branch: return !(details.defaultBranch?.isEmpty ?? true)
        case .visibility: return !(details.visibility?.isEmpty ?? true)
        case .updated: return details.lastActivityAt != nil
        case .created: return details.createdAt != nil
        }
    }
}
