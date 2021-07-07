// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class NetworksTests: XCTestCase {
    private(set) var app: XCUIApplication!
    
    /// Load an app and load networks list from list url.
    /// - Parameter transaction: if `nil`, default `Transaction` will be used
    func setupWithPaymentSession(using transaction: Transaction? = nil) throws {
        continueAfterFailure = false

        try XCTContext.runActivity(named: "Setup payment session") { _ in
            // Create payment session
            let sessionURL: URL
            
            if let transaction = transaction {
                sessionURL = try createPaymentSession(using: transaction)
            } else {
                sessionURL = try createPaymentSession(using: Transaction.loadFromTemplate())
            }

            // UI tests must launch the application that they test.
            let app = XCUIApplication()
            self.app = app
            app.launch()

            // Initial screen
            let tablesQuery = app.tables
            tablesQuery.textFields.firstMatch.typeText(sessionURL.absoluteString)
            tablesQuery.buttons["Send request"].tap()

            // Wait for loading completion
            XCTAssert(tablesQuery.firstMatch.waitForExistence(timeout: 10))
        }
    }

    private func createPaymentSession(using transaction: Transaction) throws -> URL {
        let sessionExpectation = expectation(description: "Create payment session")

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
