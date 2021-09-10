// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class DeleteButtonTests: NetworksTests {
    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .update)
                transaction.allowDelete = true
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
            }
        }

        func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .update)
                transaction.allowDelete = false
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
            }
        }

        func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .update)
                transaction.allowDelete = nil
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
            }
        }

        func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .charge)
                transaction.allowDelete = true
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
            }
        }

        func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .charge)
                transaction.allowDelete = false
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
            }
        }

        func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
            let visa = Visa()

            try XCTContext.runActivity(named: "Delete the payment method") { _ in
                var transaction = try Transaction.loadFromTemplate(operationType: .charge)
                transaction.allowDelete = nil
                try setupWithPaymentSession(using: transaction)

                app.tables.staticTexts[visa.maskedLabel].tap()
                XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
            }
        }
}
