// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class NetworksTests: XCTestCase {
    private(set) var app: XCUIApplication!

    /// Load an app and load networks list from list url.
    func setupWithPaymentSession(settings: ListSettings) throws {
        continueAfterFailure = false

        self.app = try Self.setupWithPaymentSession(settings: settings)
    }
    
    /// Load an app and load networks list from list url.
    private static func setupWithPaymentSession(settings: ListSettings) throws -> XCUIApplication {
        try XCTContext.runActivity(named: "Start payment session") { _ in
            // Create payment session
            let sessionURL = try createPaymentSession(with: settings)

            // UI tests must launch the application that they test.
            let app = XCUIApplication()
            app.launch()

            // Initial screen
            let tablesQuery = app.tables
            let textField = tablesQuery.textFields.firstMatch
            let sendRequestButton = tablesQuery.buttons["Send request"]

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
            XCTAssert(tablesQuery.firstMatch.waitForExistence(timeout: .networkTimeout))
            
            return app
        }
    }

    private static func createPaymentSession(with settings: listSettings) throws -> URL {
        var createSessionResult: Result<URL, Error>?

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
