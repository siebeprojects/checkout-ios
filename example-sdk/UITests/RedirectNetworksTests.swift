// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class RedirectNetworksTests: NetworksTests {
    func testPayPalAccept() throws {
        app.tables.staticTexts["PayPal"].tap()
        app.collectionViews.buttons["Pay"].tap()
        app.webViews.webViews.webViews.staticTexts["accept"].tap()

        _ = app.alerts.firstMatch.waitForExistence(timeout: 5)
        let result = app.alerts.staticTexts.element(boundBy: 1).label

        XCTAssertTrue(result.contains("Interaction code: PROCEED"))
        XCTAssertTrue(result.contains("Interaction reason: OK"))
    }
}
