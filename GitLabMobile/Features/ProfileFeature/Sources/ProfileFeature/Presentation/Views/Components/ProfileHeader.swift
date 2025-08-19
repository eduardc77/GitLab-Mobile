//
//  ProfileHeader.swift
//  ProfileFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import UsersDomain
import GitLabDesignSystem

public struct ProfileHeader: View {
    public let user: GitLabUser

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImageView(url: user.avatarUrl, contentMode: .fill, targetSize: CGSize(width: 56, height: 56)) {
                Circle().fill(Color(.secondarySystemFill))
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name).font(.headline)
                Text("@\(user.username)").font(.subheadline).foregroundStyle(.secondary)
                if let created = user.createdAt {
                    Text("Member since \(created, format: .dateTime.year().month().day())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
