// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

extension UIModel {
    final class PaymentSession {
        let networks: [PaymentNetwork]
        let registeredAccounts: [RegisteredAccount]?
        let presetAccount: PresetAccount?
        let context: PaymentContext

        init(networks: [TranslatedModel<ApplicableNetwork>], accounts: [TranslatedModel<AccountRegistration>]?, presetAccount: TranslatedModel<Networking.PresetAccount>?, context: PaymentContext, allowDelete: Bool?) {
            self.context = context

            self.networks = networks.map {
                let localizableButtonText = PaymentButtonLocalizableText(payment: context.payment, networkOperationType: $0.model.operationType)
                return PaymentNetwork(from: $0.model, submitButtonLocalizableText: localizableButtonText, localizeUsing: $0.translator)
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
                let localizableButtonText = PaymentButtonLocalizableText(payment: context.payment, networkOperationType: $0.model.operationType)
                return UIModel.RegisteredAccount(from: $0.model, submitButtonLocalizableText: localizableButtonText, localizeUsing: $0.translator, isDeletable: isDeletable)
            }

            // Preset account
            if let translatedPresetAccount = presetAccount {
                let warningText: String?
                if Self.shouldDisplayWarningText(for: translatedPresetAccount.model) {
                    warningText = translatedPresetAccount.translator.translation(forKey: "networks.preset.conditional.text")
                } else {
                    warningText = nil
                }

                let localizableButtonText = PaymentButtonLocalizableText(payment: context.payment, networkOperationType: translatedPresetAccount.model.operationType)
                self.presetAccount = PresetAccount(from: translatedPresetAccount.model, warningText: warningText, submitButtonLocalizableText: localizableButtonText, localizeUsing: translatedPresetAccount.translator)
            } else {
                self.presetAccount = nil
            }
        }

        /// - SeeAlso: Requirements defined in https://optile.atlassian.net/browse/PCX-995
        private static func shouldDisplayWarningText(for presetAccount: Networking.PresetAccount) -> Bool {
            return presetAccount.registered == false && presetAccount.autoRegistration == false && presetAccount.allowRecurrence == false
        }
    }
}

extension UIModel.PaymentSession {
    enum Operation: String {
        case CHARGE, UPDATE, PRESET
    }
}
