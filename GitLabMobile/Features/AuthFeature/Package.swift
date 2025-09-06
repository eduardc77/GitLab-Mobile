// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthFeature",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AuthFeature",
            targets: ["AuthFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/GitLabDesignSystem"),
        .package(path: "../../Core/GitLabNetwork")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthFeature",
            dependencies: [
                .product(name: "GitLabDesignSystem", package: "GitLabDesignSystem"),
                .product(name: "GitLabNetwork", package: "GitLabNetwork")
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature"]
        )
    ]
)
