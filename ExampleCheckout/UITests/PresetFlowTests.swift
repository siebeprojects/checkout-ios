// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class PresetFlowTests: NetworksTests {
    /// Test charging `PresetAccount` when the list does not have a preset account set
    func testNoPresetAccountSet() throws {
        let transaction = try Transaction.create(withSettings: TransactionSettings(magicNumber: .proceedOK, operationType: .preset))
        let listResult = try Self.createPaymentSession(using: transaction)
        chargePresetAccount(using: listResult)

        // Assert a result
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: .networkTimeout), "Alert didn't appear in time")

        let interactionResult = app.alerts.firstMatch.staticTexts.element(boundBy: 1).label
        XCTAssert(interactionResult.contains("ABORT"))
        XCTAssert(interactionResult.contains("CLIENTSIDE_ERROR"))
        XCTAssert(interactionResult.contains("Payment session doesn't contain preset account"))
    }
}

extension PresetFlowTests {
    func chargePresetAccount(using listResult: ListResult) {
        typeListURL(from: listResult)

        let chargePresetAccountButton = app.tables.buttons["Charge Preset Account"]
        _ = chargePresetAccountButton.waitForExistence(timeout: .uiTimeout)
        chargePresetAccountButton.tap()
    }
}
