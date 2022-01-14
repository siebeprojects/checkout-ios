// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension UIModel {
    final class PresetAccount {
        let apiModel: PayoneerCheckout.PresetAccount
        let translation: TranslationProvider

        let networkLabel: String
        let warningText: String?
        let submitButtonLabel: String
        var logo: Loadable<UIImage>?

        init(from apiModel: PayoneerCheckout.PresetAccount, warningText: String?, submitButtonLocalizationKey: String, localizeUsing localizer: TranslationProvider) {
            self.apiModel = apiModel
            self.translation = localizer
            self.warningText = warningText

            self.networkLabel = localizer.translation(forKey: "network.label")
            self.submitButtonLabel = localizer.translation(forKey: submitButtonLocalizationKey)

            logo = Loadable<UIImage>(identifier: apiModel.code.lowercased(), url: apiModel.links["logo"])
        }
    }
}

extension UIModel.PresetAccount {
    /// User-readable masked label for a registered account
    /// - Example: `VISA •••• 1234`
    var maskedAccountLabel: String {
        // Use custom transformation
        if let number = apiModel.maskedAccount?.number {
            // Expected input number format: `41 *** 1111`
            let maskedNumber = "•••• " + number.suffix(4)
            return [networkLabel, maskedNumber].joined(separator: " ")
            // Output: `VISA •••• 1234`
        } else if let iban = apiModel.maskedAccount?.iban {
            return iban.prefix(2) + " •••• " + iban.suffix(2)
            // Output: `DE •••• 24`
        } else if let displayLabel = apiModel.maskedAccount?.displayLabel {
            // Fallback to server's display label
            // Example outputs: `john.doe@example.com` (PayPal), `41 *** 1111    02 | 2022` (card)
            return displayLabel
        } else {
            return networkLabel
        }
    }

    /// Formatted expiration date based on data from a masked account. E.g. '10 / 30'.
    var expirationDate: String? {
        guard let year = apiModel.maskedAccount?.expiryYear, let month = apiModel.maskedAccount?.expiryMonth else {
            return nil
        }

        return "\(month)" + " / " + String(year).suffix(2)
    }

    var isExpired: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.twoDigitStartDate = Calendar.current.date(byAdding: .year, value: -30, to: Date())
        dateFormatter.dateFormat = "MM / yy"

        guard let expirationDateString = expirationDate, let expirationDate = dateFormatter.date(from: expirationDateString) else {
            return false
        }

        return Calendar.current.compare(expirationDate, to: Date(), toGranularity: .month) == .orderedAscending
    }
}
