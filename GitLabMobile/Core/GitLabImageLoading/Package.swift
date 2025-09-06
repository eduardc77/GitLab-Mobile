// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GitLabImageLoading",
    platforms: [
        .iOS("17.1"),
        .macOS(.v14),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "GitLabImageLoading", targets: ["GitLabImageLoading"]),
        .library(name: "GitLabImageLoadingSDWebImage", targets: ["GitLabImageLoadingSDWebImage"]),
        .library(name: "GitLabImageLoadingTestDoubles", targets: ["GitLabImageLoadingTestDoubles"])
    ],
    dependencies: [
        .package(path: "../../Core/GitLabNetwork"),
        .package(path: "../../Core/GitLabLogging"),
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.18.0")
    ],
    targets: [
        .target(name: "GitLabImageLoading"),
        .target(
            name: "GitLabImageLoadingSDWebImage",
            dependencies: [
                "GitLabImageLoading",
                .product(name: "GitLabNetwork", package: "GitLabNetwork"),
                .product(name: "GitLabLogging", package: "GitLabLogging"),
                .product(name: "SDWebImage", package: "SDWebImage")
            ]
        ),
        .target(
            name: "GitLabImageLoadingTestDoubles",
            dependencies: ["GitLabImageLoading"],
            path: "Sources/GitLabImageLoadingTestDoubles"
        ),
        .testTarget(
            name: "GitLabImageLoadingTests",
            dependencies: [
                "GitLabImageLoading",
                "GitLabImageLoadingTestDoubles"
            ]
        )
    ]
)
