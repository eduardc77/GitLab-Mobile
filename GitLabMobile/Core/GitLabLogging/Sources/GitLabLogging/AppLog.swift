//
//  AppLog.swift
//  GitLabLogging
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import OSLog

///  Centralized OSLogger instances for structured logging across the app.
public enum AppLog {
    private static let subsystem: String = "GitLabMobile"
    // Feature-oriented categories
    public static let explore = Logger(subsystem: subsystem, category: "Explore")
    public static let projects = Logger(subsystem: subsystem, category: "Projects")
    public static let issues = Logger(subsystem: subsystem, category: "Issues")
    public static let auth = Logger(subsystem: subsystem, category: "Auth")
    public static let network = Logger(subsystem: subsystem, category: "Network")
    public static let config = Logger(subsystem: subsystem, category: "Configuration")
}
