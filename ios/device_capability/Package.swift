// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "device_capability",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "device-capability", targets: ["device_capability"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "device_capability",
            dependencies: [],
            resources: []
        )
    ]
)
