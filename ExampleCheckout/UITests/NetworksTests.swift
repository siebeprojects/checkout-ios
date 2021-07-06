// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class NetworksTests: XCTestCase {
    private(set) var app: XCUIApplication!

    func setupWithPaymentSession(amount: Double = 1.99) throws {
        continueAfterFailure = false

        // Create payment session
        let sessionURL = try createPaymentSession(amount: amount)

        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        self.app = app
        app.launch()

        // Initial screen
        let tablesQuery = app.tables
        if tablesQuery.buttons["Clear text"].exists {
            tablesQuery.buttons["Clear text"].tap()
        }
        tablesQuery.textFields.firstMatch.typeText(sessionURL.absoluteString)
        tablesQuery.buttons["Send request"].tap()
    }

    private func createPaymentSession(amount: Double = 1.99) throws -> URL {
        let sessionExpectation = expectation(description: "Create payment session")
        let transaction = Transaction.loadFromTemplate(amount: amount)

        var createSessionResult: Result<URL, Error>?

        let paymentSessionService = PaymentSessionService()!
        paymentSessionService.create(using: transaction, completion: { (result) in
            createSessionResult = result
            sessionExpectation.fulfill()
        })

        wait(for: [sessionExpectation], timeout: 5)

        switch createSessionResult {
        case .success(let url): return url
        case .failure(let error):
            let attachment = XCTAttachment(subject: error)
            attachment.name = "LoadPaymentSessionError"
            add(attachment)
            throw error
        case .none: throw "Create session result wasn't set"
        }
    }
}
