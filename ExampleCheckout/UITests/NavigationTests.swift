// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

final class NavigationTests: NetworksTests {
    func testChargePresetAccount_whenEmptyURL_shouldNotStartLoading() {
        app.buttons["Charge Preset Account"].tap()
        XCTAssertTrue(app.tables.children(matching: .cell).element(boundBy: 3).buttons.firstMatch.isEnabled)
    }

    func testClose() throws {
        let listSettings = try ListSettings()
        try setupPaymentSession(with: listSettings)

        let closeButton = app.buttons["Close"]

        XCTAssertTrue(closeButton.exists)

        closeButton.tap()

        let expectation = expectation(for: NSPredicate(format: "exists == NO"), evaluatedWith: closeButton)
        wait(for: [expectation], timeout: .uiTimeout)

        XCTAssertFalse(closeButton.exists)
    }
}
