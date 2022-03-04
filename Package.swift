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
            dependencies: ["Risk"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(name: "Risk"),
        .testTarget(
            name: "PayoneerCheckoutTests",
            dependencies: ["PayoneerCheckout", "Risk"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "RiskTests",
            dependencies: ["Risk"]
        )
    ]
)
