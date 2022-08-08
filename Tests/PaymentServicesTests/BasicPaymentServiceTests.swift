// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import BasicPaymentService
@testable import Networking

final class BasicPaymentServiceTests: XCTestCase {
    func testIsSupported_whenProvidersIsNil_shouldReturnTrue() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: PaymentMethod.CREDIT_CARD.rawValue,
            providers: nil
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenProvidersIsEmpty_shouldReturnTrue() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: PaymentMethod.CREDIT_CARD.rawValue,
            providers: []
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenProvidersIsNotEmpty_shouldReturnFalse() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: PaymentMethod.CREDIT_CARD.rawValue,
            providers: ["INVALID"]
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsNotSupported_whenPaymentMethodIsNil_shouldReturnFalse() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: "INVALID",
            paymentMethod: nil,
            providers: nil
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsNotSupported_whenPaymentMethodIsNotSupported_shouldReturnFalse() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: "INVALID",
            paymentMethod: "INVALID",
            providers: nil
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsSupported_whenPaymentMethodIsNil_shouldReturnTrue() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: nil,
            providers: nil
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsSupported_whenPaymentMethodIsNotSupported_shouldReturnTrue() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: "INVALID",
            providers: nil
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsSupported_whenPaymentMethodIsSupported_shouldReturnTrue() {
        let isSupported = BasicPaymentService.isSupported(
            networkCode: BasicPaymentService.supportedNetworkCodes.first!,
            paymentMethod: PaymentMethod.CREDIT_CARD.rawValue,
            providers: nil
        )

        XCTAssertTrue(isSupported)
    }
}
