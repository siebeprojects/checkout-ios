// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
@testable import PayoneerCheckout

extension MockFactory {
    class Localization {
        private init() {}
    }
}

extension MockFactory.Localization {
    class MockTranslationProvider: TranslationProvider {
        private(set) var translations = [[String: String]]()

        init() {
            let downloadLocalizationRequest = NetworkRequest.DownloadLocalization(from: URL.example)
            let connection = MockConnection(dataSource: MockFactory.Localization.paymentPage)
            let sendRequestOperation = SendRequestOperation(connection: connection, request: downloadLocalizationRequest)

            sendRequestOperation.downloadCompletionBlock = { result in
                self.translations = [try! result.get()]
            }

            sendRequestOperation.start()
            sendRequestOperation.waitUntilFinished()
        }
    }

    static var provider: MockTranslationProvider  = { MockTranslationProvider() }()

    static var paymentPage: Data {
        let url = Bundle.module.url(forResource: "CheckoutLocalization", withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    static var paymentNetwork: Data {
        let url = Bundle.module.url(forResource: "NetworkLocalization", withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
