// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

final class NavigationTests: NetworksTests {
    func testClose() throws {
        let transaction = try Transaction()
        try setupPaymentSession(transaction: transaction)

        let closeButton = app.buttons["Close"]

        XCTAssertTrue(closeButton.exists)

        closeButton.tap()

        let expectation = expectation(for: NSPredicate(format: "exists == NO"), evaluatedWith: closeButton)
        wait(for: [expectation], timeout: .uiTimeout)

        XCTAssertFalse(closeButton.exists)
    }
}
