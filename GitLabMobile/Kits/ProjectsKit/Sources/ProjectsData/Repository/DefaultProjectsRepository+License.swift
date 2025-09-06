//
//  DefaultProjectsRepository+License.swift
//  ProjectsKit
//
//  Copyright © 2025 Eliomane.
//  Licensed under Apache License v2.0. See LICENSE file.
//

import Foundation
import ProjectsDomain
import GitLabUtilities
import ProjectsCache
import GitLabNetwork
import GitLabLogging

// swiftlint:disable function_body_length cyclomatic_complexity

// MARK: - License Detection
extension DefaultProjectsRepository {

    public func license(projectId: Int) async throws -> Data {
        // Try common license file names in order of preference
        let licenseFileNames = [
            "LICENSE",
            "LICENSE.md",
            "LICENSE.txt",
            "LICENSE.rst",
            "COPYING",
            "COPYING.md",
            "COPYING.txt",
        ]

        // Get the default branch for the project
        let defaultBranch = try await remote.fetchDefaultBranch(projectId: projectId)

        // Try each license file name until one works
        for fileName in licenseFileNames {
            do {
                return try await remote.fetchRawFile(projectId: projectId, path: fileName, ref: defaultBranch)
            } catch {
                // Continue to next file if this one doesn't exist
                continue
            }
        }

        // If no license files found, return empty data to indicate no license
        return Data()
    }

    public func licenseType(projectId: Int) async -> String? {
        do {
            let licenseData = try await license(projectId: projectId)

            // If no license data, project has no license
            guard !licenseData.isEmpty else { return nil }

            // Convert to string for analysis
            guard let licenseText = String(data: licenseData, encoding: .utf8) else {
                return "Unknown"
            }

            let lowercasedText = licenseText.lowercased()

            // 1. First priority: SPDX License Identifiers (modern standard)
            if let spdxLicense = detectSPDXLicense(in: licenseText) {
                return spdxLicense
            }

            // 2. Second priority: License name detection with improved patterns
            if let detectedLicense = detectLicenseByContent(in: lowercasedText) {
                return detectedLicense
            }

            // 3. Third priority: Copyright notice patterns (fallback)
            if let copyrightLicense = detectLicenseByCopyright(in: lowercasedText) {
                return copyrightLicense
            }

            // If we have license content but couldn't recognize the type
            return "Unknown"

        } catch {
            // Network errors or file not found - project has no license
            return nil
        }
    }

    /// Detect SPDX license identifiers (SPDX-License-Identifier: MIT)
    private func detectSPDXLicense(in licenseText: String) -> String? {
        // SPDX license identifier pattern
        let spdxPattern = #"SPDX-License-Identifier:\s*([A-Za-z0-9\-\.\(\)\+\s]+)"#
        guard let regex = try? NSRegularExpression(pattern: spdxPattern, options: [.caseInsensitive]) else {
            return nil
        }

        let nsString = licenseText as NSString
        let matches = regex.matches(in: licenseText, options: [], range: NSRange(location: 0, length: nsString.length))

        for match in matches where match.numberOfRanges > 1 {
            let licenseId = nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
            return normalizeSPDXLicense(licenseId)
        }

        return nil
    }

    /// Normalize common SPDX license variations
    private func normalizeSPDXLicense(_ licenseId: String) -> String {
        let normalizedId = licenseId.uppercased().replacingOccurrences(of: " ", with: "")

        switch normalizedId {
        case "MIT":
            return "MIT"
        case "APACHE-2.0", "APACHE2.0":
            return "Apache 2.0"
        case "GPL-3.0", "GPL3.0", "GPLV3":
            return "GPL 3.0"
        case "GPL-2.0", "GPL2.0", "GPLV2":
            return "GPL 2.0"
        case "BSD-3-CLAUSE", "BSD3CLAUSE", "BSD-3":
            return "BSD 3-Clause"
        case "BSD-2-CLAUSE", "BSD2CLAUSE", "BSD-2":
            return "BSD 2-Clause"
        case "ISC":
            return "ISC"
        case "MPL-2.0", "MPL2.0":
            return "MPL 2.0"
        case "LGPL-2.1", "LGPL2.1":
            return "LGPL 2.1"
        case "LGPL-3.0", "LGPL3.0":
            return "LGPL 3.0"
        default:
            return licenseId
        }
    }

    /// Detect licenses by content analysis (improved patterns)
    private func detectLicenseByContent(in licenseText: String) -> String? {
        // MIT License (most common)
        if licenseText.contains("mit license") ||
           licenseText.contains("permission is hereby granted") ||
           licenseText.contains("above copyright notice and this permission notice") {
            return "MIT"
        }

        // Apache License 2.0
        if licenseText.contains("apache license") &&
           (licenseText.contains("version 2.0") || licenseText.contains("apache 2.0")) {
            return "Apache 2.0"
        }

        // GNU General Public License
        if licenseText.contains("gnu general public license") || licenseText.contains("gnu gpl") {
            if licenseText.contains("version 3") || licenseText.contains("gplv3") {
                return "GPL 3.0"
            } else if licenseText.contains("version 2") || licenseText.contains("gplv2") {
                return "GPL 2.0"
            }
            return "GPL"
        }

        // BSD Licenses
        if licenseText.contains("bsd") {
            if licenseText.contains("3-clause") || licenseText.contains("new bsd") ||
               licenseText.contains("neither the name of") {
                return "BSD 3-Clause"
            } else if licenseText.contains("2-clause") || licenseText.contains("simplified") ||
                      licenseText.contains("redistribute and use in source and binary forms") {
                return "BSD 2-Clause"
            }
            return "BSD"
        }

        // ISC License
        if licenseText.contains("isc license") ||
           (licenseText.contains("permission to use, copy, modify") &&
            licenseText.contains("isc")) {
            return "ISC"
        }

        // Mozilla Public License
        if licenseText.contains("mozilla public license") ||
           licenseText.contains("mpl") {
            if licenseText.contains("2.0") {
                return "MPL 2.0"
            }
            return "MPL"
        }

        // Creative Commons
        if licenseText.contains("creative commons") {
            if licenseText.contains("cc0") || licenseText.contains("public domain") {
                return "CC0"
            } else if licenseText.contains("by-sa") {
                return "CC BY-SA"
            } else if licenseText.contains("by") {
                return "CC BY"
            }
            return "CC"
        }

        // Boost Software License
        if licenseText.contains("boost software license") ||
           (licenseText.contains("permission is hereby granted") &&
            licenseText.contains("boost")) {
            return "BSL"
        }

        // zlib License
        if licenseText.contains("zlib") ||
           licenseText.contains("this software is provided 'as-is'") {
            return "zlib"
        }

        // PostgreSQL License (similar to MIT)
        if licenseText.contains("postgresql license") ||
           licenseText.contains("postgresql") {
            return "PostgreSQL"
        }

        return nil
    }

    /// Detect licenses by copyright notice patterns
    private func detectLicenseByCopyright(in licenseText: String) -> String? {
        // FreeBSD copyright pattern often indicates BSD license
        if licenseText.contains("freebsd") || licenseText.contains("berkeley software") {
            return "BSD"
        }

        // Python Software Foundation copyright
        if licenseText.contains("python software foundation") {
            return "PSF"
        }

        // OpenSSL copyright pattern
        if licenseText.contains("openssl") {
            return "OpenSSL"
        }

        return nil
    }
}
// swiftlint:enable function_body_length cyclomatic_complexity
