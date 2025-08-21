// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabNetwork",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GitLabNetwork",
            targets: ["GitLabNetwork"]),
        .library(
            name: "GitLabNetworkTestDoubles",
            targets: ["GitLabNetworkTestDoubles"])
    ],
    dependencies: [
        .package(path: "../GitLabPersistence"),
        .package(path: "../GitLabLogging")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GitLabNetwork",
            dependencies: [
                .product(name: "GitLabPersistence", package: "GitLabPersistence"),
                .product(name: "GitLabLogging", package: "GitLabLogging")
            ]),
        .target(
            name: "GitLabNetworkTestDoubles",
            dependencies: ["GitLabNetwork"]
        ),
        .testTarget(
            name: "GitLabNetworkUnitTests",
            dependencies: ["GitLabNetwork", "GitLabNetworkTestDoubles"]
        ),
        .testTarget(
            name: "GitLabNetworkIntegrationTests",
            dependencies: ["GitLabNetwork", "GitLabNetworkTestDoubles"]
        )
    ]
)
