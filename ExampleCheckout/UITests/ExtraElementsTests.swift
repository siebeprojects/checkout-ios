//
//  ExtraElementsTests.swift
//  UITests
//
//  Created by Caio Araujo on 16.09.21.
//  Copyright © 2021 Payoneer Germany GmbH. All rights reserved.
//

import XCTest

private let topBottomElementsURL = URL(string: "https://raw.githubusercontent.com/optile/checkout-android/PCX-2004/shared-test/lists/listresult_extraelements_topbottom.json")
private let topElementURL = URL(string: "https://raw.githubusercontent.com/optile/checkout-android/PCX-2004/shared-test/lists/listresult_extraelements_top.json")
private let bottomElementURL = URL(string: "https://raw.githubusercontent.com/optile/checkout-android/PCX-2004/shared-test/lists/listresult_extraelements_bottom.json")

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
            try startPaymentSession(transaction: Transaction(), url: topBottomElementsURL)
            app.tables.staticTexts["Cards"].tap()
            XCTAssertTrue(app.textViews["Top Element Number 1 with invalid link"].exists)
            XCTAssertTrue(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenContainsLink_shouldOpenSafari() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(), url: topBottomElementsURL)
            app.staticTexts["Cards"].tap()
            app.textViews.firstMatch.links["Number 1"].tap()
            XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 1))
        }
    }

    func testExtraElements_whenTop_shouldDisplayTop() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(), url: topElementURL)
            app.staticTexts["Cards"].tap()
            XCTAssertTrue(app.textViews["Top Element Number 1 with invalid link"].exists)
        }
    }

    func testExtraElements_whenTop_shouldNotDisplayBottom() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(), url: topElementURL)
            app.tables.staticTexts["Cards"].tap()
            XCTAssertFalse(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenBottom_shouldDisplayBottom() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(), url: bottomElementURL)
            app.tables.staticTexts["Cards"].tap()
            XCTAssertTrue(app.textViews["Bottom Element Number 2 without Checkbox"].exists)
        }
    }

    func testExtraElements_whenBottom_shouldNotDisplayTop() throws {
        try XCTContext.runActivity(named: "Open payment form") { _ in
            try startPaymentSession(transaction: Transaction(), url: bottomElementURL)
            app.tables.staticTexts["Cards"].tap()
            XCTAssertFalse(app.textViews["Top Element Number 1 with invalid link"].exists)
        }
    }
}
