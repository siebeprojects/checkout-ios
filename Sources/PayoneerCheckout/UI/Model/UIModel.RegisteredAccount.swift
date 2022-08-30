// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking

extension UIModel {
    final class RegisteredAccount {
        let apiModel: AccountRegistration
        let translation: TranslationProvider
        let isDeletable: Bool

        let networkLabel: String
        let submitButtonLocalizableText: Localizable
        var logo: Loadable<UIImage>?

        init(from apiModel: AccountRegistration, submitButtonLocalizableText: Localizable, localizeUsing localizer: TranslationProvider, isDeletable: Bool) {
            self.apiModel = apiModel
            self.translation = localizer
            self.isDeletable = isDeletable

            self.networkLabel = localizer.translation(forKey: "network.label")
            self.submitButtonLocalizableText = submitButtonLocalizableText

            logo = Loadable<UIImage>(identifier: apiModel.code.lowercased(), url: apiModel.links["logo"])
        }
    }
}

extension UIModel.RegisteredAccount {
    /// User-readable masked label for a registered account
    /// - Example: `VISA •••• 1234`
    var maskedAccountLabel: String {
        // Use custom transformation
        if let number = apiModel.maskedAccount.number {
            // Expected input number format: `41 *** 1111`
            let maskedNumber = "•••• " + number.suffix(4)
            return [networkLabel, maskedNumber].joined(separator: " ")
            // Output: `VISA •••• 1234`
        } else if let iban = apiModel.maskedAccount.iban {
            return iban.prefix(2) + " •••• " + iban.suffix(2)
            // Output: `DE •••• 24`
        } else if let displayLabel = apiModel.maskedAccount.displayLabel {
            // Fallback to server's display label
            // Example outputs: `john.doe@example.com` (PayPal), `41 *** 1111    02 | 2022` (card)
            return displayLabel
        } else {
            return networkLabel
        }
    }

    /// Formatted expiration date based on data from a masked account. E.g. '10 / 30'.
    var expirationDate: String? {
        let formatter = ExpirationDateFormatter(month: apiModel.maskedAccount.expiryMonth, year: apiModel.maskedAccount.expiryYear)
        return try? formatter.text
    }

    var isExpired: Bool {
        let validator = ExpirationDateValidator(month: apiModel.maskedAccount.expiryMonth, year: apiModel.maskedAccount.expiryYear)
        return (try? validator.isExpired) ?? false
    }
}
