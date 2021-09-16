// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Defined in https://optile.atlassian.net/browse/PCX-2012
final class DeleteButtonTests: NetworksTests {
    private var paymentMethod: PaymentNetwork!

    override func setUp() {
        super.setUp()
        paymentMethod = Visa()
    }

    override func tearDown() {
        paymentMethod = nil
        super.tearDown()
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .update, allowDelete: true)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .update, allowDelete: false)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .update, allowDelete: nil)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .charge, allowDelete: true)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .charge, allowDelete: false)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
        try addPaymentMethodIfNeeded(paymentMethod)

        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction(operationType: .charge, allowDelete: nil)
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[paymentMethod.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }
}

// MARK: - Helpers

extension DeleteButtonTests {
    private func addPaymentMethodIfNeeded(_ method: PaymentNetwork) throws {
        try XCTContext.runActivity(named: "Save new payment method") { _ in
            let transaction = try Transaction(operationType: .update)
            try setupWithPaymentSession(using: transaction)

            if !app.tables.staticTexts[method.maskedLabel].exists {
                app.tables.staticTexts["Cards"].tap()
                method.submit(in: app.collectionViews)

                let isPaymentMethodAppeared = app.tables.staticTexts[method.maskedLabel].waitForExistence(timeout: .networkTimeout)
                XCTAssert(isPaymentMethodAppeared, "Payment method didn't appear in the list after saving")
            }
        }
    }
}
