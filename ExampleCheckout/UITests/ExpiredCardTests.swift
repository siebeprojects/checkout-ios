// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

final class ExpiredCardTests: NetworksTests {
    static private var validCardCustomerID: String!
    static private var expiredCardCustomerID: String!

    private class var twoDigitNextYear: String {
        let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let nextYear = Calendar.current.component(.year, from: nextYearDate)
        return String(String(nextYear).suffix(2))
    }

    override class func setUp() {
        super.setUp()

        var validCard = Card.visa
        validCard.expiryDate = "10" + twoDigitNextYear

        var expiredCard = Card.visa
        expiredCard.expiryDate = "1020"

        self.validCardCustomerID = try! PaymentService().registerCustomer(card: validCard)
        self.expiredCardCustomerID = try! PaymentService().registerCustomer(card: expiredCard)
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

            XCTAssertTrue(app.cells.element(boundBy: 0).staticTexts["10 / \(ExpiredCardTests.twoDigitNextYear)"].exists)

            for index in 1...3 {
                let cell = app.cells.element(boundBy: index)
                XCTAssertTrue(cell.exists, "Cell with a network doesn't exist, couldn't check absense of expiration date")
                XCTAssertFalse(cell.staticTexts["10 / \(ExpiredCardTests.twoDigitNextYear)"].exists)
            }
        }
    }

    func testPaymentList_whenExpiredCard_shouldShowExpirationDate_shouldShowExpirationInfoAlert() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.expiredCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            let cell = app.cells.element(boundBy: 0)

            XCTAssertTrue(cell.staticTexts["10 / 20"].exists)

            cell.buttons["expirationInfo"].tap()

            XCTAssertTrue(app.alerts.firstMatch.exists)
        }
    }

    func testPaymentDetails_whenCard_shouldShowExpirationDate() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.validCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            app.cells.element(boundBy: 0).tap()

            XCTAssertTrue(app.collectionViews.staticTexts["10 / \(ExpiredCardTests.twoDigitNextYear)"].exists)
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
