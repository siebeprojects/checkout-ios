// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayoneerCheckout",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "PayoneerCheckout",
            targets: ["PayoneerCheckout"])
    ],
    targets: [
        .target(
            name: "PayoneerCheckout",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PayoneerCheckoutTests",
            dependencies: ["PayoneerCheckout"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
