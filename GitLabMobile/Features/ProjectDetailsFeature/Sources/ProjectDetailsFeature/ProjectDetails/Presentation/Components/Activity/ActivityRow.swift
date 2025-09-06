//
//  ActivityRow.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

/// A reusable row component for activity metrics
/// This component encapsulates the common HStack pattern used for displaying
/// activity counts (issues, MRs, contributors, etc.) with consistent styling
struct ActivityRow: View {
    let activityType: ActivityType
    let count: Int?
    let isLoading: Bool

    var body: some View {
        HStack {
            Label {
                Text(activityType.title)
            } icon: {
                Image(systemName: activityType.iconName)
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            CountDisplayView(
                count: count,
                isLoading: isLoading,
                fallbackText: String(localized: ProjectDetailsL10n.none)
            )
        }
    }
}

/// A memory-efficient view for displaying counts with loading states
/// This component avoids memory leaks by:
/// 1. Computing redaction reasons once per render cycle
/// 2. Avoiding repeated array allocations in redaction logic
/// 3. Using value types and proper SwiftUI patterns
private struct CountDisplayView: View {
    let count: Int?
    let isLoading: Bool
    let fallbackText: String

    // Computed property to avoid repeated calculations
    private var redactionReason: RedactionReasons {
        if isLoading && count == nil {
            return .placeholder
        }
        return []
    }

    var body: some View {
        Text(count.map { "\($0)" } ?? fallbackText)
            .foregroundStyle(.secondary)
            .redacted(reason: redactionReason)
    }
}
