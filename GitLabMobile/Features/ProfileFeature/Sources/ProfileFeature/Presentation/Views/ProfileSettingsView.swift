//
//  ProfileSettingsView.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import AuthFeature
import GitLabNavigation

public struct ProfileSettingsView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProfileRouter.self) private var router

    public init() {}

    public var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    Task {
                        await authStore.signOut()
                        router.navigateBack()
                    }
                } label: {
                    Text(.ProfileSettingsL10n.signOut)
                }
            }
        }
        .navigationTitle(String(localized: .ProfileSettingsL10n.accountSettings))
    }
}
