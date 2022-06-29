// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class ApplePayBraintreeTests: NetworksTests {
    private let division = "Exotic-Braintree"

    /// Test if Apple Pay network exists in the list
    func testApplePayExists() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
        try setupPaymentSession(with: listSettings)

        XCTAssertTrue(app.tables.staticTexts["Apple Pay"].exists)
    }

    /// Make a test payment with Apple Pay
    func testPayment() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
        try setupPaymentSession(with: listSettings)

        app.tables.staticTexts["Apple Pay"].tap()
        app.buttons["Pay"].tap()

        // Apple Pay
        let applePay = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
        XCTAssert(applePay.wait(for: .runningForeground, timeout: .networkTimeout))

        let visaCardLabel = "Simulated Card - Visa, ‪•••• 1234‬"
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
