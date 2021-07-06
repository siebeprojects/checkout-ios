// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class RedirectNetworksTests: NetworksTests {
    func testPayPalAccept() throws {
        try setupWithPaymentSession()

        app.tables.staticTexts["PayPal"].tap()
        app.collectionViews.buttons["Pay"].tap()

        let button = app.webViews.staticTexts["accept"]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Accept button didn't appear in time")
        button.tap()

        _ = app.alerts.firstMatch.waitForExistence(timeout: 5)
        let result = app.alerts.staticTexts.element(boundBy: 1).label

        XCTAssertTrue(result.contains("Interaction code: PROCEED"))
        XCTAssertTrue(result.contains("Interaction reason: OK"))
    }

    func testPayPalFailure() throws {
        try setupWithPaymentSession()

        app.tables.staticTexts["PayPal"].tap()
        app.collectionViews.buttons["Pay"].tap()

        let button = app.webViews.staticTexts["abort"]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Abort button didn't appear in time")
        button.tap()

        _ = app.alerts.firstMatch.waitForExistence(timeout: 5)
        let title = app.alerts.staticTexts.element(boundBy: 0).label
        let message = app.alerts.staticTexts.element(boundBy: 1).label

        // Translation for TRY_OTHER_ACCOUNT/CUSTOMER_ABORT
        XCTAssertEqual(title, "Payment interrupted")
        XCTAssertEqual(message, "Please try again.")
    }
}
