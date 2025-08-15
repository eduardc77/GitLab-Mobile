//
//  ProjectList.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct PaginatedList<Row: View>: View {
    public let items: [ProjectSummary]
    public let isLoadingMore: Bool
    public let onItemAppear: (ProjectSummary) -> Void
    @ViewBuilder public var row: (ProjectSummary) -> Row

    public var body: some View {
        List {
            Section {
                ForEach(items) { project in
                    row(project)
                        .onAppear { onItemAppear(project) }
                }
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom) {
            if isLoadingMore {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(4)
                .frame(maxWidth: .infinity)
                .background(.bar)

            }
        }
    }
}
