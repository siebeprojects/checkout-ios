// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

// Flows should follow rules specified in https://optile.atlassian.net/browse/PCX-1396.
class UpdateFlowTests: NetworksTests {
    func testTryOtherAccount() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .tryOtherAccount, operationType: .update))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()
        Visa().submit(in: app.collectionViews)

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Please verify the data you entered is correct and try again, or use another payment method."
        XCTAssertEqual(expectedResult, interactionResult)
    }

    func testProceedPending() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .proceedPending, operationType: .update))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()
        Visa().submit(in: app.collectionViews)

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Please refresh or check back later for updates."
        XCTAssertEqual(expectedResult, interactionResult)
    }

    // PayPal returns `PROCEED/OK` when it updated.
    func testProceedOk() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update))
        try setupWithPaymentSession(transaction: transaction)

        let payPal = PayPalAccount()

        // Bottom sheet
        app.tables.staticTexts[payPal.label].tap()
        payPal.submit(in: app.collectionViews)

        // Webview
        let button = app.webViews.staticTexts["accept"]
        XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Accept button didn't appear in time")
        button.tap()

        // List of networks
        XCTAssert(app.tables.staticTexts[payPal.label].waitForExistence(timeout: .networkTimeout), "Table with PayPal network is not found")
    }
}

// MARK: Test: SaveDeleteNewCardPaymentMethod

extension UpdateFlowTests {
    func testSaveDeleteNewCardPaymentMethod() throws {
        let customerId = try PaymentService().registerCustomer()
        let settings = TransactionSettings(operationType: .update, customerId: customerId)
        let transaction = try Transaction.create(withSettings: settings)
        try setupWithPaymentSession(transaction: transaction)

        let visa = Visa()

        // Method was saved previously when customer was registered

        // Test deletion
        XCTContext.runActivity(named: "Test payment method deletion") { _ in
            deletePaymentMethod(withLabel: visa.maskedLabel)
            waitForLoadingCompletion()
            XCTAssert(app.tables.staticTexts["Cards"].waitForExistence(timeout: .networkTimeout))
            XCTAssertFalse(app.tables.staticTexts[visa.maskedLabel].exists, "Payment network still exists after deletion")
        }
    }

    private func deletePaymentMethod(withLabel label: String) {
        XCTContext.runActivity(named: "Delete payment method \(label)") { _ in
            app.tables.staticTexts[label].tap()
            app.navigationBars.buttons["Delete"].tap()
            app.alerts.firstMatch.buttons["Delete"].tap()
        }
    }
}

// MARK: - Class helpers

fileprivate extension UpdateFlowTests {
    /// Wait until activity indicator disappears
    func waitForLoadingCompletion() {
        XCTContext.runActivity(named: "Wait for loading completion") { _ in
            _ = app.activityIndicators.firstMatch.waitForExistence(timeout: .uiTimeout)

            // Wait until loading indicator will disappear
            let notExists = NSPredicate(format: "exists == 0")
            let activityIndicatorIsFinished = expectation(for: notExists, evaluatedWith: app.activityIndicators.firstMatch, handler: nil)
            wait(for: [activityIndicatorIsFinished], timeout: .uiTimeout)
        }
    }

    func submitAndWaitForExistence(forPaymentNetwork paymentNetwork: PaymentNetwork) {
        app.tables.staticTexts["Cards"].tap()
        paymentNetwork.submit(in: app.collectionViews)

        let isPaymentMethodAppeared = app.tables.staticTexts[paymentNetwork.maskedLabel].waitForExistence(timeout: .networkTimeout)
        XCTAssert(isPaymentMethodAppeared, "Payment method didn't appear in the list after saving")
    }
}
