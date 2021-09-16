// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class RedirectNetworksTests: NetworksTests {
    func testPayPalAccept() throws {
        try setupWithPaymentSession(using: Transaction())

        app.tables.staticTexts["PayPal"].tap()
        app.collectionViews.buttons["Pay"].tap()

        let button = app.webViews.staticTexts["accept"]
        XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Accept button didn't appear in time")
        button.tap()

        _ = app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout)
        let result = app.alerts.staticTexts.element(boundBy: 1).label

        XCTAssertTrue(result.contains("Interaction code: PROCEED"))
        XCTAssertTrue(result.contains("Interaction reason: OK"))
    }

    func testPayPalFailure() throws {
        try setupWithPaymentSession(using: Transaction())

        app.tables.staticTexts["PayPal"].tap()
        app.collectionViews.buttons["Pay"].tap()

        let button = app.webViews.staticTexts["abort"]
        XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Abort button didn't appear in time")
        button.tap()

        _ = app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout)
        let title = app.alerts.staticTexts.element(boundBy: 0).label
        let message = app.alerts.staticTexts.element(boundBy: 1).label

        // Translation for TRY_OTHER_ACCOUNT/CUSTOMER_ABORT
        XCTAssertEqual(title, "Payment interrupted")
        XCTAssertEqual(message, "Please try again.")
    }
}
