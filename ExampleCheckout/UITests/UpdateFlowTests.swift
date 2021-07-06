// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

// Flows should follow rules specified in https://optile.atlassian.net/browse/PCX-1396.
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

    func testProceedPending() throws {
        var transaction = try Transaction.loadFromTemplate(operationType: .update)
        transaction.division = "PayOne"
        try setupWithPaymentSession(using: transaction)

        // List
        app.tables.staticTexts["Cards"].tap()

        // Input
        Card.visa.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 10), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Please refresh or check back later for updates."
        XCTAssertEqual(expectedResult, interactionResult)
    }

    func testSaveNewCardPaymentMethod() throws {
        let transaction = try Transaction.loadFromTemplate(operationType: .update)
        try setupWithPaymentSession(using: transaction)

        let paymentMethodText = "Visa •••• 1111"
        deleteIfExistsPaymentMethod(withText: paymentMethodText)
        app.tables.staticTexts["Cards"].tap()
        Card.visa.submit(in: app.collectionViews)

        let isPaymentMethodAppeared = app.tables.staticTexts[paymentMethodText].waitForExistence(timeout: 5)
        XCTAssert(isPaymentMethodAppeared, "Payment method didn't appear in the list after saving")
    }

    private func deleteIfExistsPaymentMethod(withText text: String) {
        let savedMethodText = app.tables.staticTexts[text]
        if savedMethodText.waitForExistence(timeout: 5) {
            savedMethodText.tap()
            app.navigationBars.buttons["Delete"].tap()
            app.alerts.firstMatch.buttons["Delete"].tap()
        }
    }
}
