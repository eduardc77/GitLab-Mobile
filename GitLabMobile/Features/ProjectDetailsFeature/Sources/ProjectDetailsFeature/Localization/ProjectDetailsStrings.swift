//
//  ProjectDetailsStrings.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

public enum ProjectDetailsL10n {
    public static let error: LocalizedStringResource = .init(
        "pd.error",
        table: "ProjectDetails",
        bundle: .atURL(Bundle.module.bundleURL)
    )
    public static let okButtonTitle: LocalizedStringResource = .init(
        "pd.ok",
        table: "ProjectDetails",
        bundle: .atURL(Bundle.module.bundleURL)
    )
}
