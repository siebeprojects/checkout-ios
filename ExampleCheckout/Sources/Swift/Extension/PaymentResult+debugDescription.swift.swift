// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import PayoneerCheckout

extension PaymentResult {
    public override var debugDescription: String {
        let paymentErrorText: String = {
            if let cause = self.cause {
                return cause.localizedDescription
            } else {
                return "n/a"
            }
        }()

        let messageDictionary: KeyValuePairs = [
            "ResultInfo": resultInfo,
            "Interaction code": interaction.code,
            "Interaction reason": interaction.reason,
            "Error": paymentErrorText
        ]

        return messageDictionary
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}
