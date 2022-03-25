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
        validCard.expiryDate = "03" + twoDigitNextYear

        var expiredCard = Card.visa
        expiredCard.expiryDate = "0320"

        self.validCardCustomerID = try! PaymentService().registerCustomer(card: validCard)
        self.expiredCardCustomerID = try! PaymentService().registerCustomer(card: expiredCard)
    }

    override class func tearDown() {
        self.validCardCustomerID = nil
        self.expiredCardCustomerID = nil
        super.tearDown()
    }

    func testExpirationDate_whenValidCard_shouldShow() throws {
        try XCTContext.runActivity(named: "Show card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.validCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            let cell = app.tables["paymentlist"].cells.element(boundBy: 0)
            XCTAssertTrue(cell.staticTexts["03 / \(ExpiredCardTests.twoDigitNextYear)"].exists)

            for index in 1...3 {
                let cell = app.cells.element(boundBy: index)
                XCTAssertTrue(cell.exists, "Cell with a network doesn't exist, couldn't check absense of expiration date")
                XCTAssertFalse(cell.staticTexts["03 / \(ExpiredCardTests.twoDigitNextYear)"].exists)
            }

            cell.tap()

            XCTAssertTrue(app.collectionViews.staticTexts["03 / \(ExpiredCardTests.twoDigitNextYear)"].exists)
        }
    }

    func testPaymentList_whenExpiredCard_shouldShowExpirationDate_shouldShowExpirationInfoAlert() throws {
        try XCTContext.runActivity(named: "Highlight card expiration date") { _ in
            let transaction = try Transaction.create(withSettings: TransactionSettings(operationType: .update, customerId: Self.expiredCardCustomerID))
            try setupWithPaymentSession(transaction: transaction)

            let cell = app.tables["paymentlist"].cells.element(boundBy: 0)

            XCTAssertTrue(cell.staticTexts["03 / 20"].exists)

            cell.buttons["expirationInfo"].tap()

            let alert = app.alerts.firstMatch

            XCTAssertTrue(alert.exists)

            alert.scrollViews.otherElements.buttons["OK"].tap()

            cell.tap()

            app.collectionViews.buttons["expirationInfo"].tap()

            XCTAssertTrue(app.alerts.firstMatch.exists)
        }
    }
}
