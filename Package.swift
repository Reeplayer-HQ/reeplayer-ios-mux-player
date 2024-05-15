// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReeMuxPlayer",
    dependencies: [
        .package(url: "https://github.com/muxinc/mux-player-swift.git", branch: "main"),
    ],
    products: [
        .library(
            name: "ReeMuxPlayer",
            targets: ["ReeMuxPlayer"]),
    ],
    targets: [
        .target(
            name: "ReeMuxPlayer"),
    ])
