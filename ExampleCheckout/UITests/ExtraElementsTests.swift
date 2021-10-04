//
//  ExtraElementsTests.swift
//  UITests
//
//  Created by Caio Araujo on 16.09.21.
//  Copyright © 2021 Payoneer Germany GmbH. All rights reserved.
//

import XCTest

final class ExtraElementsTests: NetworksTests {
    func testExtraElements_whenNone_shouldNotDisplay() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction())
            app.staticTexts["Cards"].tap()
            XCTAssertFalse(app.textViews["Top Element Number 1 with invalid link"].exists)
            XCTAssertFalse(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenTopAndBottom_shouldDisplayBoth() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(division: "ExtraElements", checkoutConfiguration: .extraElementsTopBottom))
            app.tables.staticTexts["Cards"].tap()
            XCTAssertTrue(app.textViews["Top Element Number 1 with invalid link"].exists)
            XCTAssertTrue(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenTop_shouldDisplayTop() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(division: "ExtraElements", checkoutConfiguration: .extraElementsTop))
            app.tables.staticTexts["Cards"].tap()
            XCTAssertTrue(app.textViews["Top Element Number 1 with invalid link"].exists)
            XCTAssertFalse(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenBottom_shouldDisplayBottom() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(division: "ExtraElements", checkoutConfiguration: .extraElementsBottom))
            app.tables.staticTexts["Cards"].tap()
            XCTAssertFalse(app.textViews["Top Element Number 1 with invalid link"].exists)
            XCTAssertTrue(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenContainsCheckbox_shouldNotDisplay() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(division: "ExtraElements", checkoutConfiguration: .extraElementsTopBottom))
            app.tables.staticTexts["Cards"].tap()
            XCTAssertFalse(app.textViews["Top Element Number 2 with a Checkbox view"].exists)
            XCTAssertFalse(app.textViews["Bottom Element Number 1 with an Checkbox optional title"].exists)
        }
    }

    func testExtraElements_whenContainsLink_shouldOpenSafari() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(division: "ExtraElements", checkoutConfiguration: .extraElementsTopBottom))
            app.staticTexts["Cards"].tap()
            app.textViews.firstMatch.links["Number 1"].tap()
            XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: .uiTimeout))
        }
    }
}
