// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

final class ExpiredCardTests: NetworksTests {
    static private var validCardCustomerID: String!
    static private var expiredCardCustomerID: String!

    override class func setUp() {
        super.setUp()
        self.validCardCustomerID = try! PaymentService().registerCustomer(card: Card.visa.overriding(expiryDate: "1030"))
        self.expiredCardCustomerID = try! PaymentService().registerCustomer(card: Card.visa.overriding(expiryDate: "1020"))
    }

    override class func tearDown() {
        self.validCardCustomerID = nil
        self.expiredCardCustomerID = nil
        super.tearDown()
    }

    func testPaymentList_whenCard_shouldShowExpirationDate() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.validCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts["10 / 30"].exists)
        }
    }

    func testPaymentList_whenNotCard_shouldNotShowExpirationDate() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.validCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            for index in 1...3 {
                XCTAssertFalse(app.cells.element(boundBy: index).staticTexts["10 / 30"].exists)
            }
        }
    }

    func testPaymentDetails_whenCard_shouldShowExpirationDate() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.validCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            app.cells.element(boundBy: 0).tap()

            XCTAssertTrue(app.collectionViews.staticTexts["10 / 30"].exists)
        }
    }

    func testPaymentList_whenExpiredCard_shouldShowExpirationDate() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.expiredCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts["10 / 20"].exists)
        }
    }

    func testPaymentList_whenExpiredCard_shouldShowExpirationInfoAlert() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.expiredCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            app.cells.element(boundBy: 0).buttons["expirationInfo"].tap()

            XCTAssertTrue(app.alerts.firstMatch.exists)
        }
    }

    func testPaymentDetails_whenExpiredCard_shouldShowExpirationInfoAlert() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.expiredCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            app.cells.element(boundBy: 0).tap()

            app.collectionViews.buttons["expirationInfo"].tap()

            XCTAssertTrue(app.alerts.firstMatch.exists)
        }
    }
}
