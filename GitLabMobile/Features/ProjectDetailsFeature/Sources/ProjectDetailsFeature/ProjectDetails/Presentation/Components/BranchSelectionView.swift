//
//  BranchSelectionView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import GitLabDesignSystem
import ProjectsDomain

struct BranchSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BranchSelectionViewModel
    let currentBranch: String?
    let onBranchSelected: (String) -> Void

    init(projectId: Int, repository: any ProjectsRepository, currentBranch: String?, onBranchSelected: @escaping (String) -> Void) {
        self.currentBranch = currentBranch
        self.onBranchSelected = onBranchSelected
        self._viewModel = State(initialValue: BranchSelectionViewModel(projectId: projectId, repository: repository))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.error {
                    ContentUnavailableView {
                        Label("Failed to load branches", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error.localizedDescription)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.loadBranches()
                            }
                        }
                    }
                } else {
                    List(viewModel.branches, id: \.name) { branch in
                        Button {
                            onBranchSelected(branch.name)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(branch.name)
                                        .font(.headline)
                                    if let commit = branch.commit {
                                        Text(commit.shortId)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if branch.name == currentBranch {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle(String(localized: ProjectDetailsL10n.selectBranch))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: ProjectDetailsL10n.cancel)) {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadBranches()
            }
        }
    }
}
