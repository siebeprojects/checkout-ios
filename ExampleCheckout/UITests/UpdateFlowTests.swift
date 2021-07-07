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
        let transaction = try Transaction.loadFromTemplate(amount: .proceedPending, operationType: .update)
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

    func testSaveDeleteNewCardPaymentMethod() throws {
        let transaction = try Transaction.loadFromTemplate(operationType: .update)
        try setupWithPaymentSession(using: transaction)

        // Test save the new payment method
        let paymentMethodText = "Visa •••• 1111"
        deleteIfExistsPaymentMethod(withText: paymentMethodText)
        app.tables.staticTexts["Cards"].tap()
        Card.visa.submit(in: app.collectionViews)

        let isPaymentMethodAppeared = app.tables.staticTexts[paymentMethodText].waitForExistence(timeout: 5)
        XCTAssert(isPaymentMethodAppeared, "Payment method didn't appear in the list after saving")

        // Test deletion
        deleteIfExistsPaymentMethod(withText: paymentMethodText)
        waitForLoadingCompletion()
        XCTAssertFalse(app.tables.staticTexts[paymentMethodText].exists, "Payment network still exists after deletion")
    }

    // TODO: Test delete shouldn't appear in a CHARGE flow
    
    /// Wait until activity indicator disappears
    private func waitForLoadingCompletion() {
        XCTContext.runActivity(named: "Wait for loading completion") { _ in
            let _ = app.activityIndicators.firstMatch.waitForExistence(timeout: 1)

            // Wait until loading indicator will disappear
            let notExists = NSPredicate(format: "exists == 0")
            let activityIndicatorIsFinished = expectation(for: notExists, evaluatedWith: app.activityIndicators.firstMatch, handler: nil)
            wait(for: [activityIndicatorIsFinished], timeout: 5)
        }
    }

    private func deleteIfExistsPaymentMethod(withText text: String) {
        XCTContext.runActivity(named: "Delete payment method \(text)") { activity in
            let savedMethodText = app.tables.staticTexts[text]
            if savedMethodText.exists {
                savedMethodText.tap()
                app.navigationBars.buttons["Delete"].tap()
                app.alerts.firstMatch.buttons["Delete"].tap()
            }
        }
    }
}
