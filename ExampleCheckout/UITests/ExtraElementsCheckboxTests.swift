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
}
