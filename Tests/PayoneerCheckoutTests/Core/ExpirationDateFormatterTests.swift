// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

final class ExpirationDateFormatterTests: XCTestCase {
    func testText_whenMonthIsNil_whenYearIsNil_shouldThrowInvalidInputError() {
        let formatter = ExpirationDateFormatter(month: nil, year: nil)

        XCTAssertThrowsError(try formatter.text) { error in
            XCTAssertEqual(error as? ExpirationDateFormatterError, ExpirationDateFormatterError.invalidInput)
        }
    }

    func testText_whenMonthIsNil_whenYearIsNotNil_shouldThrowInvalidInputError() {
        let formatter = ExpirationDateFormatter(month: nil, year: 2030)

        XCTAssertThrowsError(try formatter.text) { error in
            XCTAssertEqual(error as? ExpirationDateFormatterError, ExpirationDateFormatterError.invalidInput)
        }
    }

    func testText_whenMonthIsNotNil_whenYearIsNil_shouldThrowInvalidInputError() {
        let formatter = ExpirationDateFormatter(month: 10, year: nil)

        XCTAssertThrowsError(try formatter.text) { error in
            XCTAssertEqual(error as? ExpirationDateFormatterError, ExpirationDateFormatterError.invalidInput)
        }
    }

    func testText_whenMonthNotNil_whenYearIsFourDigits_shouldReturnString() {
        let formatter = ExpirationDateFormatter(month: 10, year: 2030)
        XCTAssertEqual(try formatter.text, "10 / 30")
    }

    func testText_whenMonthNotNil_whenYearIsTwoDigits_shouldReturnString() {
        let formatter = ExpirationDateFormatter(month: 10, year: 30)
        XCTAssertEqual(try formatter.text, "10 / 30")
    }
}
