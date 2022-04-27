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
            targets: ["PayoneerCheckout"]),
        .library(
            name: "IovationRiskProvider",
            targets: ["IovationRiskProvider"]),
    ],
    targets: [
        .target(
            name: "PayoneerCheckout",
            dependencies: ["Risk", "Networking", "Logging", "Payment", "DefaultPaymentService"],
            resources: [
                .process("Resources")
            ]
        ),
        .target(name: "Networking", dependencies: ["Logging"]),
        .target(name: "Logging"),

        // Payment Services
        .target(name: "Payment", dependencies: ["Networking"]),
        .target(
            name: "DefaultPaymentService",
            dependencies: ["Networking", "Payment"],
            path: "Sources/PaymentServices/DefaultPaymentService"),

        // Risk
        .target(name: "Risk"),
        .target(
            name: "IovationRiskProvider",
            dependencies: ["Risk", "FraudForce"]),
        .binaryTarget(
            name: "FraudForce",
            path: "Sources/FraudForce/FraudForce.xcframework"),

        // Tests
        .testTarget(
            name: "PayoneerCheckoutTests",
            dependencies: ["PayoneerCheckout", "Risk", "Networking"],
            resources: [
                .process("Resources")
            ])
    ]
)
