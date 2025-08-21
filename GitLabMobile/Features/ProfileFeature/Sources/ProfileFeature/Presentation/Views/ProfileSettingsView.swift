//
//  ProfileSettingsView.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import AuthFeature

public struct ProfileSettingsView: View {
    @Environment(AuthenticationStore.self) private var authStore
    @Environment(ProfileCoordinator.self) private var coordinator

    public init() {}

    public var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    Task {
                        await authStore.signOut()
                        coordinator.navigateBack()
                    }
                } label: {
                    Text(.ProfileSettingsL10n.signOut)
                }
            }
        }
        .navigationTitle(String(localized: .ProfileSettingsL10n.accountSettings))
    }
}
