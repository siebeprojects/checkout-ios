// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

struct PaymentButtonLocalizableText: Localizable {
    let payment: Payment?
    let listOperationType: UIModel.PaymentSession.Operation

    private var defaultLocalizationKey: String {
        "button.operation." + listOperationType.rawValue.uppercased() + ".label"
    }

    func localize(using translationProvider: TranslationProvider) -> String {
        // Display amount only for CHARGE and PAYOUT flows
        switch listOperationType {
        case .CHARGE: break
        // case .PAYOUT - not yet supported
        default: return translationProvider.translation(forKey: defaultLocalizationKey)
        }

        guard let payment = payment else {
            // Fallback if `Payment` object is not present
            return translationProvider.translation(forKey: defaultLocalizationKey)
        }

        let payText: String = translationProvider.translation(forKey: "button.operation." + listOperationType.rawValue.uppercased() + ".amount.label")
        let amount = String(payment.amount)
        let combinedString = [payText, amount, payment.currency].joined(separator: " ")
        return combinedString
    }
}
