//
//  ProfileSettingsView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ProfileSettingsView: View {
    @Environment(AppEnvironment.self) private var appEnv
    @Environment(ProfileCoordinator.self) private var coordinator

    public init() {}

    public var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    Task {
                        await appEnv.authStore.signOut()
                        coordinator.navigateBack()
                    }
                } label: { Text("Sign Out") }
            }
        }
        .navigationTitle("Account Settings")
    }
}
