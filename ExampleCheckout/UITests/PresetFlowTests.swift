// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class PresetFlowTests: NetworksTests {
    /// Test charging `PresetAccount` when the list does not have a preset account set
    func testNoPresetAccountSet() throws {
        let transaction = try Transaction(magicNumber: .proceedOK, operationType: .preset)
        let listResult = try Self.createPaymentSession(using: transaction)
        typeListURL(from: listResult)
        chargePresetAccount()

        // Assert a result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("ABORT"))
        XCTAssert(interactionResult.contains("CLIENTSIDE_ERROR"))
        XCTAssert(interactionResult.contains("Payment session doesn't contain preset account"))
    }

    /// Test charging `PresetAccount` when a preset account's object is from a credit card network
    func testPresetWithAccountCard() throws {
        try XCTContext.runActivity(named: "Preset account") { _ in
            // Create payment session
            let transaction = try Transaction(magicNumber: .proceedOK, operationType: .preset)
            try setupPaymentSession(transaction: transaction)

            // Fill and submit card's data
            app.tables.staticTexts["Cards"].tap()
            Card.visa.submit(in: app.collectionViews)

            // Wait for an alert that account was preset
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(interactionResult.contains("PROCEED"))
            XCTAssert(interactionResult.contains("OK"))
        }

        // Close the alert
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // Charge the preset account
        XCTContext.runActivity(named: "Charge the preset account") { _ in
            chargePresetAccount()

            // Assert a result
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let chargeInteractionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(chargeInteractionResult.contains("PROCEED"))
            XCTAssert(chargeInteractionResult.contains("OK"))
        }
    }

    /// Test charging `PresetAccount` when the preset account's object is from a redirect network (PayPal)
    func testPresetAndChargePayPal() throws {
        try XCTContext.runActivity(named: "Preset account") { _ in
            // Create payment session
            let transaction = try Transaction(magicNumber: .nonMagicNumber, operationType: .preset)
            try setupPaymentSession(transaction: transaction)

            // Fill and submit card's data
            app.tables.staticTexts["PayPal"].tap()

            let continueButton = app.buttons["Continue"]
            XCTAssertTrue(continueButton.waitForExistence(timeout: .uiTimeout))
            continueButton.tap()

            // Wait for an alert that account was preset
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(interactionResult.contains("PROCEED"))
            XCTAssert(interactionResult.contains("OK"))
        }

        // Close the alert
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // Charge the preset account
        XCTContext.runActivity(named: "Charge the preset account") { _ in
            chargePresetAccount()

            // Accept in a webview
            let button = app.webViews.staticTexts["accept"]
            XCTAssertTrue(button.waitForExistence(timeout: .networkTimeout), "Accept button didn't appear in time")
            button.tap()

            // Assert a result
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let chargeInteractionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(chargeInteractionResult.contains("PROCEED"))
            XCTAssert(chargeInteractionResult.contains("OK"))
        }
    }

    /// Test charging `PresetAccount` that requires 3DS2 validation using redirect.
    func testPresetAndChargeCardWith3DS2() throws {
        try XCTContext.runActivity(named: "Preset account") { _ in
            // Create payment session
            let transaction = try Transaction(magicNumber: .threeDS2, operationType: .preset)
            try setupPaymentSession(transaction: transaction)

            // Fill and submit card's data
            app.tables.staticTexts["Cards"].tap()
            Card.visa.submit(in: app.collectionViews)

            // Wait for an alert that account was preset
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(interactionResult.contains("PROCEED"))
            XCTAssert(interactionResult.contains("OK"))
        }

        // Close the alert
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // Charge the preset account
        XCTContext.runActivity(named: "Charge the preset account") { _ in
            chargePresetAccount()

            // 3DS challenge
            let requestChallengeButton = app.webViews.staticTexts["request challenge"]
            XCTAssertTrue(requestChallengeButton.waitForExistence(timeout: .networkTimeout), "Accept button didn't appear in time")
            requestChallengeButton.tap()

            let acceptButton = app.webViews.staticTexts["accept"]
            XCTAssertTrue(acceptButton.waitForExistence(timeout: .networkTimeout), "Accept button didn't appear in time")
            acceptButton.tap()

            // Assert a result
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let chargeInteractionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(chargeInteractionResult.contains("PROCEED"))
            XCTAssert(chargeInteractionResult.contains("OK"))
        }
    }

    /// Test preset a preset with 1-click
    func testPresetAPresetAccount() throws {
        let card = Card.visa

        try XCTContext.runActivity(named: "Preset account") { _ in
            // Create payment session
            let transaction = try Transaction(magicNumber: .proceedOK, operationType: .preset)
            try setupPaymentSession(transaction: transaction)

            // Fill and submit card's data
            app.tables.staticTexts["Cards"].tap()
            card.submit(in: app.collectionViews)

            // Wait for an alert that account was preset
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(interactionResult.contains("PROCEED"))
            XCTAssert(interactionResult.contains("OK"))
        }

        // Close the alert
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // Charge the preset account
        XCTContext.runActivity(named: "Preset a preset account") { _ in
            app.tables.buttons["Show Payment List"].tap()

            let visaCell = app.tables.staticTexts[card.maskedLabel]
            XCTAssert(visaCell.waitForExistence(timeout: .networkTimeout))
            visaCell.tap()

            // Assert a result
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")
            let chargeInteractionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            XCTAssert(chargeInteractionResult.contains("PROCEED"))
            XCTAssert(chargeInteractionResult.contains("OK"))
        }
    }
}

private extension PresetFlowTests {
    func chargePresetAccount() {
        let chargePresetAccountButton = app.tables.buttons["Charge Preset Account"]
        _ = chargePresetAccountButton.waitForExistence(timeout: .uiTimeout)
        chargePresetAccountButton.tap()
    }
}
