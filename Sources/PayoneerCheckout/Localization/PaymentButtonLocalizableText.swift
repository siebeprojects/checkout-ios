// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

struct PaymentButtonLocalizableText: Localizable {
    let payment: Payment?
    let networkOperationType: String

    private var defaultLocalizationKey: String {
        "button.operation." + networkOperationType + ".label"
    }

    func localize(using translationProvider: TranslationProvider) -> String {
        // Display amount only for CHARGE and PAYOUT flows
        guard ["CHARGE", "PAYOUT"].contains(networkOperationType) else {
            return translationProvider.translation(forKey: defaultLocalizationKey)
        }

        guard let payment = payment else {
            // Fallback if `Payment` object is not present
            return translationProvider.translation(forKey: defaultLocalizationKey)
        }

        let amount = String(payment.amount) + " " + payment.currency

        let buttonLabel: String = {
            let amountPlaceholderKey = "${amount}"
            let localizationWithPlaceholder: String = translationProvider.translation(forKey: "button.operation." + networkOperationType + ".amount.label")
            return localizationWithPlaceholder.replacingOccurrences(of: amountPlaceholderKey, with: amount)
        }()

        return buttonLabel
    }
}
