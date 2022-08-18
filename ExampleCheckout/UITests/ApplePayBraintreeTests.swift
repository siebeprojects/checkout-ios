// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

/// Tests for Apple Pay braintree module. Tests are optional, in case of errors they could be skipped instead of throwing failures.
class ApplePayBraintreeTests: NetworksTests {
    private let division = "Exotic-Braintree"

    // MARK: - List

    /// Test if Apple Pay network exists in the list
    func testApplePayExists() throws {
        do {
            let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
            try setupPaymentSession(with: listSettings)
        } catch {
            throw XCTSkip("There is a problem setting up Braintree enviroment: \(error)")
        }

        XCTAssertTrue(app.tables.staticTexts["Apple Pay"].exists)
    }

    // MARK: - Charge

    func testCharge() throws {
        do {
            try chargeApplePay()
        } catch {
            throw XCTSkip("There is a problem making Apple Pay payment through Braintree: \(error)")
        }
    }

    /// Make a test payment with Apple Pay
    private func chargeApplePay() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: division)
        try setupPaymentSession(with: listSettings)

        app.tables.staticTexts["Apple Pay"].tap()
        app.buttons["Pay"].tap()

        try payInApplePayApplication()

        // Check OperationResult
        guard app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout) else {
            throw "Alert didn't appear in time"
        }

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        guard interactionResult.contains("PROCEED"), interactionResult.contains("OK") else {
            throw "Interaction result is not PROCEED/OK"
        }
    }

    // MARK: - Preset

    func testPresetAndCharge() throws {
        do {
            try presetAndCharge()
        } catch {
            throw XCTSkip("There is a problem making Apple Pay payment through Braintree: \(error)")
        }
    }

    private func presetAndCharge() throws {
        try XCTContext.runActivity(named: "Preset account") { _ in
            // Create payment session
            let listSettings = try ListSettings(magicNumber: .nonMagicNumber, operationType: .preset, division: division)
            try setupPaymentSession(with: listSettings)

            // Fill and submit card's data
            app.tables.staticTexts["Apple Pay"].tap()

            let continueButton = app.buttons["Continue"]
            XCTAssertTrue(continueButton.waitForExistence(timeout: .uiTimeout))
            continueButton.tap()

            // Check OperationResult
            guard app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout) else {
                throw "Alert didn't appear in time"
            }

            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            guard interactionResult.contains("PROCEED"), interactionResult.contains("OK") else {
                throw "Interaction result is not PROCEED/OK"
            }
        }

        // Close the alert
        app.alerts.firstMatch.buttons.firstMatch.tap()

        // Charge the preset account
        try XCTContext.runActivity(named: "Charge the preset account") { _ in
            let chargePresetAccountButton = app.tables.buttons["Charge Preset Account"]
            _ = chargePresetAccountButton.waitForExistence(timeout: .uiTimeout)
            chargePresetAccountButton.tap()

            try payInApplePayApplication()

            // Check OperationResult
            guard app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout) else {
                throw "Alert didn't appear in time"
            }

            let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
            guard interactionResult.contains("PROCEED"), interactionResult.contains("OK") else {
                throw "Interaction result is not PROCEED/OK"
            }
        }
    }
}

private extension ApplePayBraintreeTests {
    func payInApplePayApplication() throws {
        let applePay = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
        guard applePay.wait(for: .runningForeground, timeout: .networkTimeout) else {
            throw "Timeout: waiting of Apple Pay presentation"
        }

        // iOS 14 and lower don't allow interaction with Apple Pay view controller.
        // iOS 15 use a button instead of cell so we could guess version using a code below.
        let cardSelectionButton = applePay.buttons.containing(label: "1234").firstMatch
        guard cardSelectionButton.waitForExistence(timeout: .uiTimeout) else {
            throw "Card selection button doesn't exists, possible unsupported iOS version for Apple Pay UI tests"
        }

        cardSelectionButton.tap()
        applePay.tables.cells.containing(label: "1234").firstMatch.tap()
        applePay.buttons["Pay with Passcode"].tap()
    }
}

private extension XCUIElementQuery {
    func containing(label: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", label)
        return self.containing(predicate)
    }
}
