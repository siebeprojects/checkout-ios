// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Defined in https://optile.atlassian.net/browse/PCX-2012
final class DeleteButtonTests: NetworksTests {
    private static var paymentMethod: PaymentNetwork { Visa() }

    static private var customerId: String!
    
    override class func setUp() {
        super.setUp()
        self.customerId = try! PaymentService().registerCustomer()
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: true, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: false, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, allowDelete: nil, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: true, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: false, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .charge, allowDelete: nil, customerId: Self.customerId))
            try setupWithPaymentSession(transaction: transaction)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }
}
