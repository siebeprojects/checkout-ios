// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

class SharedTranslationProviderTests: XCTestCase {
    func testSuccessDownload() {
        // Prepare
        let localTranslation = ["test1": "value1", "test2": "value2"]
        let connection = MockConnection(dataSource: MockFactory.Localization.paymentPage)
        let provider = SharedTranslationProvider(localTranslations: localTranslation)
        let paymentNetworkLangURL = URL(string: "https://resources.sandbox.oscato.com/resource/lang/VASILY_DEMO/en_US/VISAELECTRON.properties")!

        // Download
        let promise = expectation(description: "SharedTranslationProvider completion")
        provider.download(from: paymentNetworkLangURL, using: connection) { error in
            if let error = error {
                XCTFail(error)
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)

        // Snapshot for debugging
        let attachment = XCTAttachment(plistObject: provider.translations)
        self.add(attachment)

        // Perform checks
        XCTAssertEqual(provider.translations.count, 2)
        XCTAssertEqual(provider.translations[0]["button.operation.CHARGE.label"], "Pay")
        XCTAssertEqual(provider.translations[0].count, 83)
        XCTAssertEqual(provider.translations[1], localTranslation)
    }

    func testFailedDownload() {
        let testError = TestError(description: "Test error")
        let connection = MockConnection(dataSource: testError)
        let provider = SharedTranslationProvider()

        let promise = expectation(description: "SharedTranslationProvider completion")

        provider.download(from: URL.example, using: connection) { error in
            if let error = error {
                XCTAssertEqual(error.localizedDescription, testError.localizedDescription)
            } else {
                XCTFail("Expected failure because framework is not intended to work without downloaded shared dictionary")
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 1)
    }
}
