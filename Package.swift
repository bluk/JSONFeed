// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONFeed",
    products: [
        .library(
            name: "JSONFeed",
            targets: ["JSONFeed"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.2.3"
        ),
    ],
    targets: [
        .target(
            name: "JSONFeed",
            dependencies: ["AnyCodable"]
        ),
        .testTarget(
            name: "JSONFeedTests",
            dependencies: ["JSONFeed"]
        ),
    ]
)
