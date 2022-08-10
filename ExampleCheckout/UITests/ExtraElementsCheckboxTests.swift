// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

final class ExtraElementsCheckboxTests: NetworksTests {
    func testOptionalCheckbox() throws {
        let checkboxSettings = try ListSettings(division: "ExtraElements", checkoutConfiguration: .extraElementsCheckboxes)
        try setupPaymentSession(with: checkboxSettings)

        app.staticTexts["Cards"].tap()
        XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))

        XCTContext.runActivity(named: "Test OPTIONAL checkbox") { _ in
            let checkbox = app.switches["extraElement_OPTIONAL"]
            XCTAssert(checkbox.exists)
            XCTAssertEqual(checkbox.value as! String, "0")
        }

        XCTContext.runActivity(named: "Test OPTIONAL_PRESELECTED checkbox") { _ in
            let checkbox = app.switches["extraElement_OPTIONAL_PRESELECTED"]
            XCTAssert(checkbox.exists)
            XCTAssertEqual(checkbox.value as! String, "1")
        }
    }

    func testRequiredCheckbox() throws {
        let checkboxSettings = try ListSettings(division: "ExtraElements", checkoutConfiguration: .extraElementsCheckboxes)
        try setupPaymentSession(with: checkboxSettings)

        app.staticTexts["Cards"].tap()
        XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))

        // TODO: Add test for validation error message or popup

        XCTContext.runActivity(named: "Test REQUIRED checkbox") { _ in
            let checkbox = app.switches["extraElement_REQUIRED"]
            XCTAssert(checkbox.exists)
            XCTAssertEqual(checkbox.value as! String, "0")
        }

        XCTContext.runActivity(named: "Test REQUIRED_PRESELECTED checkbox") { _ in
            let checkbox = app.switches["extraElement_REQUIRED_PRESELECTED"]
            XCTAssert(checkbox.exists)
            XCTAssertEqual(checkbox.value as! String, "1")
        }
    }

    func testForcedCheckbox() throws {
        let checkboxSettings = try ListSettings(division: "ExtraElements", checkoutConfiguration: .extraElementsCheckboxes)
        try setupPaymentSession(with: checkboxSettings)

        app.staticTexts["Cards"].tap()
        XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))

        // TODO: Add test for displaying information why checkboxes were disabled

        XCTContext.runActivity(named: "Test FORCED checkbox") { _ in
            let checkbox = app.switches["extraElement_FORCED"]
            XCTAssert(checkbox.exists)
            XCTAssertFalse(checkbox.isEnabled)
            XCTAssertEqual(checkbox.value as! String, "1")
        }

        XCTContext.runActivity(named: "Test FORCED_DISPLAYED checkbox") { _ in
            let checkbox = app.switches["extraElement_FORCED"]
            XCTAssert(checkbox.exists)
            XCTAssertFalse(checkbox.isEnabled)
            XCTAssertEqual(checkbox.value as! String, "1")
        }
    }

    // MARK: - Validation

    /// Test validation error message appears for switches with `REQUIRED` mode when switch is changed.
    func testValidationMessagesOnSwitchChange() throws {
        let checkboxSettings = try ListSettings(division: "ExtraElements", checkoutConfiguration: .extraElementsCheckboxes)
        try setupPaymentSession(with: checkboxSettings)

        app.staticTexts["Cards"].tap()
        XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))

        XCTContext.runActivity(named: "Test REQUIRED checkbox validation message") { _ in
            let cell = app.cells.containing(.switch, identifier: "extraElement_REQUIRED")
            let validationErrorText = cell.staticTexts["REQUIRED error message"]
            let checkbox = cell.switches.firstMatch

            XCTAssertFalse(validationErrorText.exists)
            checkbox.tap(withNumberOfTaps: 2, numberOfTouches: 1)
            XCTAssertTrue(validationErrorText.exists)
        }

        XCTContext.runActivity(named: "Test REQUIRED_PRESELECTED checkbox validation message") { _ in
            let cell = app.cells.containing(.switch, identifier: "extraElement_REQUIRED_PRESELECTED")
            let validationErrorText = cell.staticTexts["REQUIRED_PRESELECTED error message"]
            let checkbox = cell.switches.firstMatch

            XCTAssertFalse(validationErrorText.exists)
            checkbox.tap()
            XCTAssertTrue(validationErrorText.exists)
        }
    }

    /// Test validation error message appears for switch with `REQUIRED` mode when "Pay" was tapped.
    func testValidationMessagesOnFullCheck() throws {
        let checkboxSettings = try ListSettings(division: "ExtraElements", checkoutConfiguration: .extraElementsCheckboxes)
        try setupPaymentSession(with: checkboxSettings)

        app.staticTexts["Cards"].tap()
        XCTAssert(app.navigationBars["Payment details"].waitForExistence(timeout: .uiTimeout))
        app.swipeUp()
        app.buttons["Pay"].tap()

        XCTContext.runActivity(named: "Test REQUIRED checkbox validation message") { _ in
            let cell = app.cells.containing(.switch, identifier: "extraElement_REQUIRED")
            let validationErrorText = cell.staticTexts["REQUIRED error message"]

            XCTAssertTrue(validationErrorText.exists)
        }
    }
}
