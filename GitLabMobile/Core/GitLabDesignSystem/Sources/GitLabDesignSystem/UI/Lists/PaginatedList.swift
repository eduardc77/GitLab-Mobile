//
//  PaginatedList.swift
//  GitLabDesignSystem
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI

public struct PaginatedList<Item: Identifiable, Row: View>: View {
    public let items: [Item]
    public let isLoadingMore: Bool
    public let onItemAppear: (Item) -> Void
    @ViewBuilder public var row: (Item) -> Row

    public init(
        items: [Item],
        isLoadingMore: Bool,
        onItemAppear: @escaping (Item) -> Void,
        row: @escaping (Item) -> Row
    ) {
        self.items = items
        self.isLoadingMore = isLoadingMore
        self.onItemAppear = onItemAppear
        self.row = row
    }

    public var body: some View {
        List {
            Section {
                ForEach(items) { item in
                    row(item)
                        .onAppear { onItemAppear(item) }
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
                    Text(String(localized: LocalizedStringResource(
                        "ds.loading_more",
                        table: "DesignSystem",
                        bundle: .atURL(Bundle.module.bundleURL)
                    )))
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
