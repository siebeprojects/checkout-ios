// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension UIModel {
    final class PaymentSession {
        let networks: [PaymentNetwork]
        let registeredAccounts: [RegisteredAccount]?
        let presetAccount: PresetAccount?
        let context: PaymentContext

        init(networks: [TranslatedModel<ApplicableNetwork>], accounts: [TranslatedModel<AccountRegistration>]?, presetAccount: TranslatedModel<PayoneerCheckout.PresetAccount>?, context: PaymentContext, allowDelete: Bool?) {
            self.context = context

            let buttonLocalizationKey = "button.operation." + context.listOperationType.rawValue.uppercased() + ".label"

            self.networks = networks.map {
                .init(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator)
            }

            // Registered accounts

            // Defined in https://optile.atlassian.net/browse/PCX-2012
            let isDeletable: Bool = {
                switch context.listOperationType {
                case .UPDATE:
                    return (allowDelete == nil) || (allowDelete == true)
                case .CHARGE:
                    return allowDelete == true
                case .PRESET:
                    return false
                }
            }()

            self.registeredAccounts = accounts?.map {
                UIModel.RegisteredAccount(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator, isDeletable: isDeletable)
            }

            // Preset account
            if let translatedPresetAccount = presetAccount {
                let warningText: String?
                if Self.shouldDisplayWarningText(for: translatedPresetAccount.model) {
                    warningText = translatedPresetAccount.translator.translation(forKey: "networks.preset.conditional.text")
                } else {
                    warningText = nil
                }

                self.presetAccount = PresetAccount(from: translatedPresetAccount.model, warningText: warningText, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: translatedPresetAccount.translator)
            } else {
                self.presetAccount = nil
            }
        }

        /// - SeeAlso: Requirements defined in https://optile.atlassian.net/browse/PCX-995
        private static func shouldDisplayWarningText(for presetAccount: PayoneerCheckout.PresetAccount) -> Bool {
            return presetAccount.registered == false && presetAccount.autoRegistration == false && presetAccount.allowRecurrence == false
        }
    }
}

extension UIModel.PaymentSession {
    enum Operation: String {
        case CHARGE, UPDATE, PRESET
    }
}
