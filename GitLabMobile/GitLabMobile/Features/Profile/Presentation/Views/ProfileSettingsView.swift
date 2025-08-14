//
//  ProfileSettingsView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct ProfileSettingsView: View {
    public let signOut: () async -> Void

    public var body: some View {
        List {
            Section {
                Button(role: .destructive) { Task { await signOut() } } label: { Text("Sign Out") }
            }
        }
        .navigationTitle("Account Settings")
    }
}
