//
//  HomeNavigationStack.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import HomeFeature
import GitLabNavigation
import ProjectsDomain
import UserProjectsFeature
import ProjectDetailsFeature

struct HomeNavigationStack: View {
    @Environment(ProjectsDependencies.self) private var projectsDependencies
    @State private var router = HomeRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeRootView()
                .navigationDestination(for: HomeRouter.Destination.self) { destination in
                    switch destination {
                    case .projects:
                        ProjectsListView(
                            repository: projectsDependencies.repository,
                            scope: .combined,
                            navigationContext: .home(router)
                        )
                    case .groups:
                        // Temporary hardcoded Strings
                        Text("Groups")
                    case .issues:
                        Text("Issues")
                    case .mergeRequests:
                        Text("MergeRequests")
                    case .todo:
                        Text("Todo")
                    case .milestones:
                        Text("Milestones")
                    case .snippets:
                        Text("Snippets")
                    case .activity:
                        Text("Activity")
                    case .projectDetail(let project):
                        ProjectDetailsView(projectId: project.id, repository: projectsDependencies.repository)
                    }
                }
        }
        .environment(router)
    }
}
