// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

final class PresetAccountTests: XCTestCase {
    func testExpirationDate_whenMonthIsNil_whenYearIsNil_shouldReturnNil() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: nil, expiryYear: nil), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertNil(account.expirationDate)
    }

    func testExpirationDate_whenMonthIsNil_whenYearIsNotNil_shouldReturnNil() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: nil, expiryYear: 2030), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertNil(account.expirationDate)
    }

    func testExpirationDate_whenMonthIsNotNil_whenYearIsNil_shouldReturnNil() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: 10, expiryYear: nil), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertNil(account.expirationDate)
    }

    func testExpirationDate_whenMonthNotNil_whenYearIsFourDigits_shouldReturnString() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: 10, expiryYear: 2030), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertEqual(account.expirationDate, "10 / 30")
    }

    func testExpirationDate_whenMonthNotNil_whenYearIsTwoDigits_shouldReturnString() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: 10, expiryYear: 30), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertEqual(account.expirationDate, "10 / 30")
    }

    func testIsExpired_whenMonthIsNil_whenYearIsNil_shouldReturnFalse() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: nil, expiryYear: nil), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }

    func testIsExpired_whenMonthIsNil_whenYearIsNotNil_shouldReturnFalse() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: nil, expiryYear: 2030), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }

    func testIsExpired_whenMonthIsNotNil_whenYearIsNil_shouldReturnFalse() {
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: 10, expiryYear: nil), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }

    func testIsExpired_whenDateIsNow_shouldReturnFalse() {
        let month = Calendar.current.component(.month, from: Date())
        let year = Calendar.current.component(.year, from: Date())
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: month, expiryYear: year), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }

    func testIsExpired_whenDateIsLastMonth_shouldReturnTrue() {
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let month = Calendar.current.component(.month, from: lastMonthDate)
        let year = Calendar.current.component(.year, from: lastMonthDate)
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: month, expiryYear: year), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertTrue(account.isExpired)
    }

    func testIsExpired_whenDateIsLastYear_shouldReturnTrue() {
        let lastYearDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let month = Calendar.current.component(.month, from: lastYearDate)
        let year = Calendar.current.component(.year, from: lastYearDate)
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: month, expiryYear: year), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertTrue(account.isExpired)
    }

    func testIsExpired_whenDateIsNextMonth_shouldReturnFalse() {
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        let month = Calendar.current.component(.month, from: nextMonthDate)
        let year = Calendar.current.component(.year, from: nextMonthDate)
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: month, expiryYear: year), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }

    func testIsExpired_whenDateIsNextYear_shouldReturnFalse() {
        let nextYearDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let month = Calendar.current.component(.month, from: nextYearDate)
        let year = Calendar.current.component(.year, from: nextYearDate)
        let account = UIModel.PresetAccount(from: PresetAccount(expiryMonth: month, expiryYear: year), warningText: nil, submitButtonLocalizationKey: "", localizeUsing: MockFactory.Localization.MockTranslationProvider())
        XCTAssertFalse(account.isExpired)
    }
}
