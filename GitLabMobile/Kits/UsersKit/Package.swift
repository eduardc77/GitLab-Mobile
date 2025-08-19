// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UsersKit",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "UsersData", targets: ["UsersData"]),
        .library(name: "UsersDomain", targets: ["UsersDomain"])
    ],
    dependencies: [
        .package(path: "../../Core/GitLabNetwork")
    ],
    targets: [
        .target(
            name: "UsersData",
            dependencies: [
                "UsersDomain",
                .product(name: "GitLabNetwork", package: "GitLabNetwork")
            ],
            path: "Sources/UsersData"
        ),
        .target(
            name: "UsersDomain",
            path: "Sources/UsersDomain"
        )
    ]
)
