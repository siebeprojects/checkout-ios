// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class BraintreeApplePayTests: NetworksTests {
    func testApplePayExists() throws {
        let listSettings = try ListSettings(magicNumber: .proceedOK, operationType: .charge, division: "Exotic-Braintree")
        try setupPaymentSession(with: listSettings)

        XCTAssertTrue(app.tables.staticTexts["Apple Pay"].exists)
    }
}
