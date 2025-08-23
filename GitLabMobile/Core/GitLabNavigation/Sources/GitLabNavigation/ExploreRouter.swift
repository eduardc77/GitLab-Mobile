//
//  ExploreRouter.swift
//  GitLabNavigation
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import SwiftUI
import Observation
import ProjectsDomain

@MainActor
@Observable
public final class ExploreRouter {
    public var path = NavigationPath()

    public init() {}

    public enum Destination: Hashable {
        case projects
        case users
        case groups
        case topics
        case snippets
        case projectDetail(ProjectSummary)
    }

    public func navigate(to destination: Destination) { path.append(destination) }
    public func navigateBack() { if !path.isEmpty { path.removeLast() } }
    public func navigateToRoot() { path.removeLast(path.count) }
}
