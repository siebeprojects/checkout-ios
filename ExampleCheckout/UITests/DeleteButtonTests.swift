// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Defined in https://optile.atlassian.net/browse/PCX-2012
final class DeleteButtonTests: NetworksTests {
    private static let paymentMethod = Card.visa

    static private var customerId: String!
    
    override class func setUp() {
        super.setUp()
        self.customerId = try! PaymentService().registerCustomer(card: paymentMethod)
    }

    override class func tearDown() {
        self.customerId = nil
        super.tearDown()
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .update, allowDelete: true, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .update, allowDelete: false, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenUpdateFlow_whenAllowDeleteIsNil_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .update, allowDelete: nil, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsTrue_shouldShow() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .charge, allowDelete: true, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertTrue(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsFalse_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .charge, allowDelete: false, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }

    func testDeleteButton_whenChargeFlow_whenAllowDeleteIsNil_shouldHide() throws {
        try XCTContext.runActivity(named: "Delete the payment method") { _ in
            let listSettings = try ListSettings(operationType: .charge, allowDelete: nil, customerId: Self.customerId)
            try setupPaymentSession(with: listSettings)

            app.tables.staticTexts[Self.paymentMethod.maskedLabel].firstMatch.tap()
            XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
            XCTAssertFalse(app.navigationBars.buttons["Delete"].exists)
        }
    }
}
