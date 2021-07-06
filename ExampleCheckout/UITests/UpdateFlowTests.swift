// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class UpdateFlowTests: NetworksTests {
    func testTryOtherAccount() throws {
        let transaction = try Transaction.loadFromTemplate(amount: .tryOtherAccount, operationType: .update)
        try setupWithPaymentSession(using: transaction)

        // List
        app.tables.staticTexts["Cards"].tap()

        // Input
        Card.visa.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 10), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Please verify the data you entered is correct and try again, or use another payment method."
        XCTAssertEqual(expectedResult, interactionResult)
    }
    

}
