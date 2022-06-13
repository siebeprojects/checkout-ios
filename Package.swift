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
        .library(
            name: "ApplePayBraintreePaymentService",
            targets: ["ApplePayBraintreePaymentService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/braintree/braintree_ios", from: "5.10.0"),
    ],
    targets: [
        .target(
            name: "PayoneerCheckout",
            dependencies: ["Risk", "Networking", "Logging", "Payment", "BasicPaymentService"],
            resources: [.process("Resources")]),
        .target(
            name: "Networking",
            dependencies: ["Logging"]),
        .target(
            name: "Logging"),

        // Payment Services
        .target(
            name: "Payment",
            dependencies: ["Networking"]),
        .target(
            name: "BasicPaymentService",
            dependencies: ["Networking", "Payment"],
            path: "Sources/PaymentServices/BasicPaymentService"),
        .target(
            name: "ApplePayBraintreePaymentService",
            dependencies: ["PayoneerCheckout", "Networking", "Payment", .product(name: "BraintreeApplePay", package: "braintree_ios")],
            path: "Sources/PaymentServices/ApplePayBraintreePaymentService"),

        // Risk
        .target(
            name: "Risk"),
        .target(
            name: "IovationRiskProvider",
            dependencies: ["Risk", "FraudForce"]),
        .binaryTarget(
            name: "FraudForce",
            path: "Sources/FraudForce/FraudForce.xcframework"),

        // Tests
        .testTarget(
            name: "PayoneerCheckoutTests",
            dependencies: ["PayoneerCheckout", "Risk", "Networking", "IovationRiskProvider"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "PaymentTests",
            dependencies: ["Payment", "Networking"])
    ]
)
