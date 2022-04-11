// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout
import IovationRiskProvider

@objc public final class Checkout: NSObject {
    @objc public func presentPaymentList(from presenter: UIViewController, listURL: URL, completion: @escaping (_ result: CheckoutResult) -> Void) {
        let configuration = CheckoutConfiguration(
            listURL: listURL,
            appearance: .default,
            riskProviders: [IovationRiskProvider.self]
        )

        let checkout = PayoneerCheckout.Checkout(configuration: configuration)

        checkout.presentPaymentList(from: presenter) { result in
            completion(CheckoutResult(result: result))
        }
    }
}

@objc public final class CheckoutResult: NSObject {
    @objc public let text: String

    @objc init(result: PayoneerCheckout.CheckoutResult) {
        let paymentErrorText: String = {
            if let cause = result.cause {
                return cause.localizedDescription
            } else {
                return "n/a"
            }
        }()

        let messageDictionary: KeyValuePairs = [
            "ResultInfo": result.resultInfo,
            "Interaction code": result.interaction.code,
            "Interaction reason": result.interaction.reason,
            "Error": paymentErrorText
        ]

        self.text = messageDictionary
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}
