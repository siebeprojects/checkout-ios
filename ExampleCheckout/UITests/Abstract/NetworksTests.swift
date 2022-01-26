// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class NetworksTests: XCTestCase {
    private(set) var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        self.app = XCUIApplication()
        app.launch()
    }

    /// Load an app and load networks list from list url.
    @discardableResult func setupWithPaymentSession(transaction: Transaction) throws -> ListResult {
        try XCTContext.runActivity(named: "Setup with payment session") { _ in
            // Create payment session
            let session = try Self.createPaymentSession(using: transaction)

            typeListURL(from: session)
            
            let sendRequestButton = app.tables.buttons["Show Payment List"]
            _ = sendRequestButton.waitForExistence(timeout: .uiTimeout)
            sendRequestButton.tap()

            // Wait for loading completion
            let chooseMethodText = app.tables.staticTexts["Cards"]
            XCTAssert(chooseMethodText.waitForExistence(timeout: .networkTimeout))

            return session
        }
    }

    /// Type `links.self` url from `ListResult` in list url text field
    func typeListURL(from listResult: ListResult) {
        let tablesQuery = app.tables
        let textField = tablesQuery.textFields.firstMatch

        let sessionURL = listResult.links["self"]!

        if #available(iOS 15, *) {
            textField.doubleTap()
            UIPasteboard.general.string = sessionURL.absoluteString
            app.menuItems["Paste"].tap()
        } else {
            textField.typeText(sessionURL.absoluteString)
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
