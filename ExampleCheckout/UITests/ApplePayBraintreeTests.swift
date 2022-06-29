// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Tests for Apple Pay braintree module. Tests are optional, in case of errors they could be skipped instead of throwing failures.
class ApplePayBraintreeTests: NetworksTests {
    private let division = "Exotic-Braintree"

    /// Test if Apple Pay network exists in the list
    func testApplePayExists() throws {
        do {
            let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
            try setupPaymentSession(with: listSettings)
        } catch {
            throw XCTSkip("There is a problem setting up Braintree enviroment: \(error)")
        }

        XCTAssertTrue(app.tables.staticTexts["Apple Pay"].exists)
    }

    func testPayment() throws {
        do {
            try makeApplePayPayment()
        } catch {
            throw XCTSkip("There is a problem making Apple Pay payment through Braintree: \(error)")
        }
    }

    /// Make a test payment with Apple Pay
    private func makeApplePayPayment() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
        try setupPaymentSession(with: listSettings)

        app.tables.staticTexts["Apple Pay"].tap()
        app.buttons["Pay"].tap()

        // Apple Pay
        let applePay = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
        XCTAssert(applePay.wait(for: .runningForeground, timeout: .networkTimeout))

        let visaCardLabel = "Simulated Card - Visa, •••• 1234"
        applePay.buttons[visaCardLabel].tap()
        applePay.tables.cells[visaCardLabel].tap()
        applePay.buttons["Pay with Passcode"].tap()

        // Check OperationResult
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("PROCEED"))
        XCTAssert(interactionResult.contains("OK"))
    }
}
