// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension UIModel {
    final class RegisteredAccount {
        let apiModel: AccountRegistration
        let translation: TranslationProvider
        let isDeletable: Bool

        let networkLabel: String
        let submitButtonLabel: String
        var logo: Loadable<UIImage>?

        init(from apiModel: AccountRegistration, submitButtonLocalizationKey: String, localizeUsing localizer: TranslationProvider, isDeletable: Bool) {
            self.apiModel = apiModel
            self.translation = localizer
            self.isDeletable = isDeletable

            self.networkLabel = localizer.translation(forKey: "network.label")
            self.submitButtonLabel = localizer.translation(forKey: submitButtonLocalizationKey)

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

    var expirationDate: String? {
        guard let year = apiModel.maskedAccount.expiryYear, let month = apiModel.maskedAccount.expiryMonth else { return nil }
        return "\(month)" + " / " + String(year).suffix(2)
    }
}
