//
//  SignInView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct SignInView: View {
    @Environment(AppEnvironment.self) private var appEnv

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Connect to GitLab")
                .font(.headline)

            switch appEnv.authStore.status {
            case .authenticating:
                ProgressView("Loading...")
            case .unauthenticated, .authenticated:
                Button {
                    appEnv.authStore.signIn()
                } label: {
                    Label("Sign in with GitLab", systemImage: "person.crop.circle.badge.plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("Error", isPresented: .constant(appEnv.authStore.errorMessage != nil), actions: {
            Button("OK") { appEnv.authStore.clearError() }
        }, message: { Text(appEnv.authStore.errorMessage ?? "") })
    }
}
