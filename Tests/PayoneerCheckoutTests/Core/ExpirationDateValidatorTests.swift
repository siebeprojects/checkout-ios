// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

final class ExpirationDateValidatorTests: XCTestCase {
    func testIsExpired_whenMonthIsNil_whenYearIsNil_shouldThrowInvalidInputError() {
        let validator = ExpirationDateValidator(month: nil, year: nil)

        XCTAssertThrowsError(try validator.isExpired) { error in
            XCTAssertEqual(error as? ExpirationDateValidatorError, ExpirationDateValidatorError.invalidInput)
        }
    }

    func testIsExpired_whenMonthIsNil_whenYearIsNotNil_shouldThrowInvalidInputError() {
        let validator = ExpirationDateValidator(month: nil, year: 2030)

        XCTAssertThrowsError(try validator.isExpired) { error in
            XCTAssertEqual(error as? ExpirationDateValidatorError, ExpirationDateValidatorError.invalidInput)
        }
    }

    func testIsExpired_whenMonthIsNotNil_whenYearIsNil_shouldThrowInvalidInputError() {
        let validator = ExpirationDateValidator(month: 10, year: nil)

        XCTAssertThrowsError(try validator.isExpired) { error in
            XCTAssertEqual(error as? ExpirationDateValidatorError, ExpirationDateValidatorError.invalidInput)
        }
    }

    func testIsExpired_whenMonthIsNotNil_whenYearIs90_shouldReturnFalse() {
        let validator = ExpirationDateValidator(month: 10, year: 90)
        XCTAssertFalse(try validator.isExpired)
    }

    func testIsExpired_whenDateIsNow_shouldReturnFalse() {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())

        let validator = ExpirationDateValidator(month: month, year: year)
        XCTAssertFalse(try validator.isExpired)
    }

    func testIsExpired_whenDateIsLastMonth_shouldReturnTrue() {
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let month = Calendar.current.component(.month, from: lastMonthDate)
        let year = Calendar.current.component(.year, from: lastMonthDate)

        let validator = ExpirationDateValidator(month: month, year: year)
        XCTAssertTrue(try validator.isExpired)
    }

    func testIsExpired_whenDateIsLastYear_shouldReturnTrue() {
        let lastYearDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let month = Calendar.current.component(.month, from: lastYearDate)
        let year = Calendar.current.component(.year, from: lastYearDate)

        let validator = ExpirationDateValidator(month: month, year: year)
        XCTAssertTrue(try validator.isExpired)
    }

    func testIsExpired_whenDateIsNextMonth_shouldReturnFalse() {
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        let month = Calendar.current.component(.month, from: nextMonthDate)
        let year = Calendar.current.component(.year, from: nextMonthDate)

        let validator = ExpirationDateValidator(month: month, year: year)
        XCTAssertFalse(try validator.isExpired)
    }

    func testIsExpired_whenDateIsNextYear_shouldReturnFalse() {
        let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let month = Calendar.current.component(.month, from: nextYearDate)
        let year = Calendar.current.component(.year, from: nextYearDate)

        let validator = ExpirationDateValidator(month: month, year: year)
        XCTAssertFalse(try validator.isExpired)
    }

    func testIsExpired_whenTwoDigitYearIsMoreThan30YearsAgo_shouldReturnFalse() {
        let lowerBoundaryDate = Calendar.current.date(byAdding: .year, value: -31, to: Date())!
        let year = "\(Calendar.current.component(.year, from: lowerBoundaryDate))".suffix(2)

        let validator = ExpirationDateValidator(month: 10, year: Int(year)!)
        XCTAssertFalse(try validator.isExpired)
    }

    func testIsExpired_whenTwoDigitYearIs30YearsAgo_shouldReturnTrue() {
        let lowerBoundaryDate = Calendar.current.date(byAdding: .year, value: -30, to: Date())!
        let year = "\(Calendar.current.component(.year, from: lowerBoundaryDate))".suffix(2)

        let validator = ExpirationDateValidator(month: 10, year: Int(year)!)
        XCTAssertTrue(try validator.isExpired)
    }

    func testIsExpired_whenTwoDigitYearIsLessThan30YearsAgo_shouldReturnTrue() {
        let lowerBoundaryDate = Calendar.current.date(byAdding: .year, value: -29, to: Date())!
        let year = "\(Calendar.current.component(.year, from: lowerBoundaryDate))".suffix(2)

        let validator = ExpirationDateValidator(month: 10, year: Int(year)!)
        XCTAssertTrue(try validator.isExpired)
    }
}
