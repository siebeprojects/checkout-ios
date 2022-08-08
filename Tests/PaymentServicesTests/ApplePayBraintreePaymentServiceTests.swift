// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import ApplePayBraintreePaymentService
@testable import Networking

final class ApplePayBraintreePaymentServiceTests: XCTestCase {
    func testIsSupported_whenNetworkCodeIsInvalid_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: "INVALID",
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenPaymentMethodIsNil_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: nil,
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenPaymentMethodIsInvalid_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: "INVALID",
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenNetworkCodeIsValid_whenPaymentMethodIsValid_shouldReturnTrue() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenProvidersIsNil_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: nil
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenProvidersIsEmpty_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: []
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenProvidersIsInvalid_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: ["PROVIDER"]
        )

        XCTAssertFalse(isSupported)
    }

    func testIsSupported_whenProviderIsValid_shouldReturnTrue() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenValidProviderIsFirst_shouldReturnTrue() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: [ApplePayBraintreePaymentService.braintreeProviderCode, "PROVIDER"]
        )

        XCTAssertTrue(isSupported)
    }

    func testIsSupported_whenValidProviderIsNotFirst_shouldReturnFalse() {
        let isSupported = ApplePayBraintreePaymentService.isSupported(
            networkCode: ApplePayBraintreePaymentService.applePayNetworkCode,
            paymentMethod: ApplePayBraintreePaymentService.applePayPaymentMethod,
            providers: ["PROVIDER", ApplePayBraintreePaymentService.braintreeProviderCode]
        )

        XCTAssertFalse(isSupported)
    }
}
