// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Defined in https://optile.atlassian.net/browse/PCX-2012
class DeleteButtonTests: NetworksTests {
    let visa = Visa()

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .update)
            transaction.allowDelete = true
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .update)
            transaction.allowDelete = false
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .update)
            transaction.allowDelete = nil
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .charge)
            transaction.allowDelete = true
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .charge)
            transaction.allowDelete = false
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            var transaction = try Transaction.loadFromTemplate(operationType: .charge)
            transaction.allowDelete = nil
            try setupWithPaymentSession(using: transaction)

            app.tables.staticTexts[visa.maskedLabel].tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }
}
