// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "NetworkS",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "NetworkS",
            targets: ["NetworkS"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkS",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkSTests",
            dependencies: ["NetworkS"],
            resources: [
                .process("httpbin.org.cer"),
                .process("Assets.xcassets")
            ]
        )
    ]
)
