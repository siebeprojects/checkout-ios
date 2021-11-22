// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
@testable import PayoneerCheckout

extension MockFactory {
    class ListResult {
        private init() {}
    }
}

extension MockFactory.ListResult {
    static var paymentSession: UIModel.PaymentSession {
        let listResult = try! JSONDecoder().decode(PayoneerCheckout.ListResult.self, from: listResultData)

        let translatedNetworks = listResult.networks.applicable.map {
            TranslatedModel(model: $0, translator: MockFactory.Localization.provider)
        }

        let context = UIModel.PaymentContext(operationType: .CHARGE, extraElements: nil)
        return UIModel.PaymentSession(networks: translatedNetworks, accounts: nil, presetAccount: nil, context: context, allowDelete: nil)
    }

    static var listResultData: Data {
        let url = Bundle.current.url(forResource: "ListResult", withExtension: "json")!
        let jsonData = try! Data(contentsOf: url)
        return jsonData
    }
}
