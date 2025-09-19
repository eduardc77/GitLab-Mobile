//
//  LocalizedStringResource.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

// Shared, reusable localized strings for UI elements across modules
public extension LocalizedStringResource {
    enum DesignSystemL10n {
        public static let loading = LocalizedStringResource(
            "ds.loading",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let updated = LocalizedStringResource(
            "ds.updated",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let loadingMore = LocalizedStringResource(
            "ds.loading_more",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let none = LocalizedStringResource(
            "ds.none",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
