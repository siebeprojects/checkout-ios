// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class CardsTests: NetworksTests {

    // MARK: Success Card Payment

    func testProceedOk() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .proceedOK, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()
        Card.visa.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "ResultInfo: Approved Interaction code: PROCEED Interaction reason: OK Error: n/a"
        XCTAssertEqual(expectedResult, interactionResult)
    }

    func testProceedPending() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .proceedPending, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()
        Card.visa.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "ResultInfo: Pending, you have to check the status later Interaction code: PROCEED Interaction reason: PENDING Error: n/a"
        XCTAssertEqual(expectedResult, interactionResult)
    }

    // MARK: Retry Card Payment

    func testRetry() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .retry, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()
        let card = Card.visa
        card.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        // Retry alert
        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Something went wrong. Please try again later or use another payment method."
        XCTAssertEqual(expectedResult, interactionResult)

        // Check input fields
        app.alerts.buttons.firstMatch.tap()
        let nameTextField = app.collectionViews.textFields["e.g. John Doe"]
        XCTAssert(nameTextField.exists, "Couldn't find holder name input field")
        XCTAssertEqual(nameTextField.value as? String, card.holderName, "Couldn't find previosly typed holder name")
    }

    func testTryOtherNetwork() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .tryOtherNetwork, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)
        let card = Card.visa

        XCTAssert(app.tables.staticTexts.contains(text: card.label))

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Alert
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "Please verify the data you entered is correct and try again, or use another payment method."
        XCTAssertEqual(expectedResult, interactionResult)

        // After TRY_OTHER_NETWORK response cards shouldn't contain Visa payment method
        app.alerts.buttons.firstMatch.tap()
        XCTAssert(app.tables.staticTexts["Cards"].waitForExistence(timeout: .networkTimeout))
        XCTAssertFalse(app.tables.staticTexts.contains(text: card.label))
    }

    func testTryOtherAccount() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .tryOtherAccount, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)
        let card = Card.visa

        XCTAssert(app.tables.staticTexts.contains(text: card.label))

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Alert
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "This payment method cannot be used at the moment. Please use another method."
        XCTAssertEqual(expectedResult, interactionResult)

        // After TRY_OTHER_ACCOUNT response, cards should still contain Visa payment method
        app.alerts.buttons.firstMatch.tap()
        XCTAssert(app.tables.staticTexts["Cards"].waitForExistence(timeout: .networkTimeout))
        XCTAssert(app.tables.staticTexts.contains(text: card.label))
    }

    // MARK: Failed Card Payment

    func testRiskDetected() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .nonMagicNumber, operationType: .charge))
        try setupWithPaymentSession(transaction: transaction)

        app.tables.staticTexts["Cards"].tap()

        // The `ANDROID_TESTING` merchant on Integration has been setup to block the Mastercard number: 5105105105105100
        var card = Card.mastercard
        card.number = "5105105105105100"
        card.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("ABORT"))
        XCTAssert(interactionResult.contains("RISK_DETECTED"))
    }

    // MARK: Interface tests

    func testClearButton() throws {
        try setupWithPaymentSession(transaction: Transaction.create())

        // List
        app.tables.staticTexts["Cards"].tap()

        // Input
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["13 to 19 digits"].tap()

        let clearButton = app.collectionViews.buttons["Clear text"]
        let cardNumberTextField = collectionViewsQuery.textFields["13 to 19 digits"]

        XCTAssertFalse(clearButton.exists, "Clear button should be hidden")

        cardNumberTextField.typeText("4111")
        XCTAssertTrue(clearButton.exists, "Clear button should be visible")

        clearButton.tap()
        XCTAssertEqual(cardNumberTextField.value as? String, "13 to 19 digits", "Text wasn't cleared")
        XCTAssertFalse(clearButton.exists, "Clear button should be hidden")
    }
}

fileprivate extension XCUIElementQuery {
    func contains(text: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        let elementQuery = self.containing(predicate)
        return elementQuery.count != 0
    }
}
