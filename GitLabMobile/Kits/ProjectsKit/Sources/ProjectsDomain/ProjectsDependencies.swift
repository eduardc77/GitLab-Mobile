//
//  ProjectsDependencies.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Observation

@Observable
@MainActor
public final class ProjectsDependencies {
    @ObservationIgnored public let repository: any ProjectsRepository

    public init(repository: any ProjectsRepository) { self.repository = repository }
}
