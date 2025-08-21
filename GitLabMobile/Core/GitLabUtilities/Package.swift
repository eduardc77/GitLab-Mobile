// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabUtilities",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GitLabUtilities",
            targets: ["GitLabUtilities"])
    ],
    dependencies: [
        .package(path: "../GitLabLogging"),
        .package(path: "../GitLabPersistence"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can define a module or a test suite.
        .target(
            name: "GitLabUtilities",
            dependencies: [
                .product(name: "GitLabLogging", package: "GitLabLogging"),
                .product(name: "GitLabPersistence", package: "GitLabPersistence"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]),
        .target(
            name: "GitLabUtilitiesTestDoubles",
            dependencies: ["GitLabUtilities"]
        ),
        .testTarget(
            name: "GitLabUtilitiesUnitTests",
            dependencies: ["GitLabUtilities", "GitLabUtilitiesTestDoubles"]
        )
    ]
)
