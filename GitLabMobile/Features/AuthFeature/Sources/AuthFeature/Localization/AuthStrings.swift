//
//  AuthStrings.swift
//  AuthFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

extension LocalizedStringResource {
    enum AuthL10n {
        static let connectTitle = LocalizedStringResource(
            "auth.connect_title",
            table: "Auth",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let loading = LocalizedStringResource(
            "auth.loading",
            table: "Auth",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let signInWithGitLab = LocalizedStringResource(
            "auth.sign_in_with_gitlab",
            table: "Auth",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let errorTitle = LocalizedStringResource(
            "auth.error.title",
            table: "Auth",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let okButtonTitle = LocalizedStringResource(
            "auth.error.ok",
            table: "Auth",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
