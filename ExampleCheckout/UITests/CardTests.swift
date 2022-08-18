// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class CardsTests: NetworksTests {

    // MARK: Success Card Payment

    func testProceedOk() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge)
        try setupPaymentSession(with: listSettings)

        app.tables.staticTexts["Cards"].tap()
        Card.visa.submit(in: app.collectionViews)

        // Check result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedResult = "ResultInfo: Approved Interaction code: PROCEED Interaction reason: OK Error: n/a"
        XCTAssertEqual(expectedResult, interactionResult)
    }

    func testProceedPending() throws {
        let listSettings = try ListSettings(magicNumber: .proceedPending, operationType: .charge)
        try setupPaymentSession(with: listSettings)

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
        let listSettings = try ListSettings(magicNumber: .retry, operationType: .charge)
        try setupPaymentSession(with: listSettings)

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
        let listSettings = try ListSettings(magicNumber: .tryOtherNetwork, operationType: .charge)
        try setupPaymentSession(with: listSettings)
        let card = Card.visa

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
    }

    func testTryOtherAccount() throws {
        let listSettings = try ListSettings(magicNumber: .tryOtherAccount, operationType: .charge)
        try setupPaymentSession(with: listSettings)
        let card = Card.visa

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
    }

    // MARK: Failed Card Payment

    func testRiskDetected() throws {
        let listSettings = try ListSettings(magicNumber: .nonMagicNumber, operationType: .charge)
        try setupPaymentSession(with: listSettings)

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
        try setupPaymentSession(with: ListSettings())

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

    func testFailUpdateSavedAccount() throws {
        var card = Card.visa
        card.number = "4111111111111111"

        let customerID = try PaymentService().registerCustomer(card: card)

        let listSettings = try ListSettings(magicNumber: .forceFail, operationType: .update, customerId: customerID)
        try setupPaymentSession(with: listSettings)

        app.tables.staticTexts[card.maskedLabel].tap()

        app.collectionViews.textFields["MM / YY"].typeText("1032")
        app.collectionViews.textFields["3 digits"].typeText(card.verificationCode)
        app.collectionViews.buttons.firstMatch.tap()

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssertTrue(interactionResult.contains("ABORT"))
        XCTAssertTrue(interactionResult.contains("SYSTEM_FAILURE"))
    }

    func testGETRedirectTESTPSPAccept() throws {
        let listSettings = try ListSettings(magicNumber: .threeDS2, operationType: .charge)
        try setupPaymentSession(with: listSettings)

        var card = Card.visa
        card.number = "4111111111111400"

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Webview

        let button = app.webViews.staticTexts["accept payment"]
        XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        button.tap()

        // Alert

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("PROCEED"))
        XCTAssert(interactionResult.contains("OK"))
    }

    func testGETRedirectTESTPSPAbort() throws {
        let listSettings = try ListSettings(magicNumber: .threeDS2, operationType: .charge)
        try setupPaymentSession(with: listSettings)

        var card = Card.visa
        card.number = "4111111111111400"

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Webview

        let challengeButton = app.webViews.staticTexts["request challenge"]
        XCTAssertTrue(challengeButton.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        challengeButton.tap()

        let acceptButton = app.webViews.staticTexts["abort"]
        XCTAssertTrue(acceptButton.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        acceptButton.tap()

        // Alert

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let alertTitle = app.alerts.firstMatch.staticTexts.element(boundBy: 0).label
        let expectedTitle = "Payment interrupted"
        XCTAssertEqual(alertTitle, expectedTitle)

        let alertText = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedText = "Please try again."
        XCTAssertEqual(alertText, expectedText)
    }

    func testPOSTRedirectTESTPSPAccept() throws {
        let listSettings = try ListSettings(magicNumber: .threeDS2, operationType: .charge)
        try setupPaymentSession(with: listSettings)

        var card = Card.visa
        card.number = "4111111111111418"

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Webview

        let button = app.webViews.staticTexts["accept payment"]
        XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        button.tap()

        // Alert

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("PROCEED"))
        XCTAssert(interactionResult.contains("OK"))
    }

    func testPOSTRedirectTESTPSPAbort() throws {
        let listSettings = try ListSettings(magicNumber: .threeDS2, operationType: .charge)
        try setupPaymentSession(with: listSettings)

        var card = Card.visa
        card.number = "4111111111111418"

        app.tables.staticTexts["Cards"].tap()
        card.submit(in: app.collectionViews)

        // Webview

        let challengeButton = app.webViews.staticTexts["request challenge"]
        XCTAssertTrue(challengeButton.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        challengeButton.tap()

        let acceptButton = app.webViews.staticTexts["abort"]
        XCTAssertTrue(acceptButton.waitForExistence(timeout: .networkTimeout), "Button didn't appear in time")
        acceptButton.tap()

        // Alert

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let alertTitle = app.alerts.firstMatch.staticTexts.element(boundBy: 0).label
        let expectedTitle = "Payment interrupted"
        XCTAssertEqual(alertTitle, expectedTitle)

        let alertText = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        let expectedText = "Please try again."
        XCTAssertEqual(alertText, expectedText)
    }
}
