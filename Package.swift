// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReeMuxPlayer",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "ReeMuxPlayer",
            targets: ["ReeMuxPlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/muxinc/mux-player-swift.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "ReeMuxPlayer",
            dependencies: [
                .product(name: "MuxPlayerSwift", package: "mux-player-swift"),
            ]),
    ])
