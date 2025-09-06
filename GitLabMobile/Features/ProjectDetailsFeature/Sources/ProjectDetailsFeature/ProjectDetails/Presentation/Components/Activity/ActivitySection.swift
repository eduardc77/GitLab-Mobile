//
//  ActivitySection.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ProjectsDomain
import GitLabDesignSystem
import GitLabNavigation

struct ActivitySection: View {
    let openIssuesCount: Int?
    let openMergeRequestsCount: Int?
    let contributorsCount: Int?
    let releasesCount: Int?
    let milestonesCount: Int?
    let isLoadingExtras: Bool
    let licenseType: String?
    let isLoadingLicense: Bool
    let details: ProjectDetails?
    let router: (any FeatureRouter)?

    var body: some View {
        Section {
            ForEach(ActivityType.allCases, id: \.self) { activityType in
                ActivityRow(
                    activityType: activityType,
                    count: count(for: activityType),
                    isLoading: isLoadingExtras
                )
            }
            if let details = details {
                licenseNavigationRow(for: details)
            }
        }
    }

    private func count(for activityType: ActivityType) -> Int? {
        switch activityType {
        case .openIssues: return openIssuesCount
        case .openMRs: return openMergeRequestsCount
        case .contributors: return contributorsCount
        case .releases: return releasesCount
        case .milestones: return milestonesCount
        }
    }

    private func licenseNavigationRow(for details: ProjectDetails) -> some View {
        Button {
            router?.navigateToProjectLicense(projectId: details.id, projectPath: details.pathWithNamespace)
        } label: {
            HStack {
                Label {
                    Text(String(localized: ProjectDetailsL10n.openLicense))
                } icon: {
                    Image(systemName: "doc.text")
                        .font(.callout)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if isLoadingLicense && licenseType == nil {
                    Text(String(localized: ProjectDetailsL10n.none))
                        .foregroundStyle(.secondary)
                        .redacted(reason: .placeholder)
                } else {
                    Text(licenseType ?? String(localized: ProjectDetailsL10n.none))
                        .foregroundStyle(.secondary)
                }
                if licenseType != nil || isLoadingLicense {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(licenseType == nil && !isLoadingLicense)
    }
}
