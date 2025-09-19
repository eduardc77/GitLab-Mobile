// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MergeRequestsUI",
    platforms: [
        .iOS("17.1")
    ],
    products: [
        .library(
            name: "MergeRequestsUI",
            targets: ["MergeRequestsUI"]
        )
    ],
    dependencies: [
        .package(path: "../../../Kits/ProjectsKit")
    ],
    targets: [
        .target(
            name: "MergeRequestsUI",
            dependencies: [
                .product(name: "ProjectsKit", package: "ProjectsKit")
            ],
            path: "Sources/MergeRequestsUI"
        )
    ]
)

