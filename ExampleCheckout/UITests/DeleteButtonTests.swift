// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Defined in https://optile.atlassian.net/browse/PCX-2012
final class DeleteButtonTests: NetworksTests {
    private static var paymentMethod: PaymentNetwork { Visa() }

    override func setUpWithError() throws {
        try super.setUpWithError()
        try addPaymentMethodIfNeeded(Self.paymentMethod)
    }

    // Remove the created network after tests are completed
    class override func tearDown() {
        do {
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: true))
            let app = try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].firstMatch.tap()
            app.navigationBars.buttons["Delete"].tap()
            app.alerts.firstMatch.buttons["Delete"].tap()
            _ = app.tables.staticTexts["Cards"].waitForExistence(timeout: .networkTimeout)
        } catch {
            XCTFail("Payment network wasn't removed")
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: true))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: false))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: nil))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: true))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: false))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: nil))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }
}

// MARK: - Helpers

extension DeleteButtonTests {
    private func addPaymentMethodIfNeeded(_ method: PaymentNetwork) throws {
        try XCTContext.runActivity(named: "Save new payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update))
            try setupWithPaymentSession(transaction: transaction)

            if !app.tables.staticTexts[method.maskedLabel].exists {
                app.tables.staticTexts["Cards"].tap()
                method.submit(in: app.collectionViews)

                let isPaymentMethodAppeared = app.tables.staticTexts[method.maskedLabel].waitForExistence(timeout: .networkTimeout)
                XCTAssert(isPaymentMethodAppeared, "Payment method didn't appear in the list after saving")
            }
        }
    }
}
