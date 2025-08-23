//
//  ExploreNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import ExploreFeature
import ProjectsDomain
import ProjectDetailsFeature
import GitLabNavigation

struct ExploreNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @State private var router = ExploreRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            ExploreRootView()
                .navigationDestination(for: ExploreRouter.Destination.self) { destination in
                    switch destination {
                    case .projects:
                        ExploreProjectsView(repository: projectsDependencies.repository)
                    case .projectDetail(let project):
                        ProjectDetailsView(projectId: project.id, repository: projectsDependencies.repository)
                    case .users:
                        Text("Users")
                    case .groups:
                        Text("Groups")
                    case .topics:
                        Text("Topics")
                    case .snippets:
                        Text("Snippets")
                    }
                }
        }
        .environment(router)
    }
}
