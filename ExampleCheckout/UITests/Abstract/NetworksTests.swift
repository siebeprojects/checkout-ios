// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class NetworksTests: XCTestCase {
    private(set) var app: XCUIApplication!

    /// Load an app and load networks list from list url.
    func setupWithPaymentSession(transaction: Transaction) throws {
        continueAfterFailure = false

        self.app = try Self.setupWithPaymentSession(transaction: transaction)
    }

    /// Load an app and load networks list from list url.
    static func setupWithPaymentSession(transaction: Transaction) throws -> XCUIApplication {
        try XCTContext.runActivity(named: "Start payment session") { _ in
            // Create payment session
            let session = try createPaymentSession(using: transaction)

            // UI tests must launch the application that they test.
            let app = XCUIApplication()
            app.launch()

            // Initial screen
            let tablesQuery = app.tables
            let textField = tablesQuery.textFields.firstMatch
            let sendRequestButton = tablesQuery.buttons["Send request"]

            let sessionURL = session.links["self"]!

            if #available(iOS 15, *) {
                textField.doubleTap()
                UIPasteboard.general.string = sessionURL.absoluteString
                app.menuItems["Paste"].tap()
                _ = sendRequestButton.waitForExistence(timeout: .uiTimeout)
            } else {
                textField.typeText(sessionURL.absoluteString)
            }

            sendRequestButton.tap()

            // Wait for loading completion
            let chooseMethodText = app.tables.staticTexts["Cards"]
            XCTAssert(chooseMethodText.waitForExistence(timeout: .networkTimeout))

            return app
        }
    }

    static func createPaymentSession(using transaction: Transaction) throws -> ListResult {
        var createSessionResult: Result<ListResult, Error>?

        let paymentSessionService = try PaymentSessionService()

        let semaphore = DispatchSemaphore(value: 0)
        paymentSessionService.create(using: transaction) { result in
            createSessionResult = result
            semaphore.signal()
        }

        let timeoutResult = semaphore.wait(timeout: .now() + .networkTimeout)

        guard case .success = timeoutResult else {
            throw "Timeout waiting for payment session service reply. Most likely it's a network timeout error."
        }

        switch createSessionResult {
        case .success(let url): return url
        case .failure(let error): throw error
        case .none: throw "Create session result wasn't set"
        }
    }
}
