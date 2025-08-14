//
//  SignedOutView.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct SignedOutView: View {
    public let signIn: () -> Void

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclam")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Sign in to continue")
                .font(.headline)
            Button(action: signIn) {
                Label("Sign in with GitLab", systemImage: "globe")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
