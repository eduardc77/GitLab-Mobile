//
//  LoadPhase.swift
//  GitLabMobile
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation

/// Shared list-loading phase used by stores to keep behavior consistent.
public enum LoadPhase: Equatable {
    case idle
    case initialLoading
    case loading
    case searching
    case reloading
    case loadingMore
    case failed(String)
}
