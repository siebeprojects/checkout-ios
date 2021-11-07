// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension UIModel {
    final class PaymentSession {
        let networks: [UIModel.PaymentNetwork]
        let registeredAccounts: [UIModel.RegisteredAccount]?
        let context: UIModel.PaymentContext

        init(networks: [TranslatedModel<ApplicableNetwork>], accounts: [TranslatedModel<AccountRegistration>]?, context: UIModel.PaymentContext, allowDelete: Bool?) {
            self.context = context

            let buttonLocalizationKey = "button.operation." + context.listOperationType.rawValue.uppercased() + ".label"

            self.networks = networks.map {
                .init(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator)
            }

            /// Defined in https://optile.atlassian.net/browse/PCX-2012
            let isDeletable: Bool = {
                switch context.listOperationType {
                case .UPDATE:
                    return (allowDelete == nil) || (allowDelete == true)
                case .CHARGE:
                    return allowDelete == true
                }
            }()

            self.registeredAccounts = accounts?.map {
                UIModel.RegisteredAccount(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator, isDeletable: isDeletable)
            }
        }
    }
}

extension UIModel.PaymentSession {
    enum Operation: String {
        case CHARGE, UPDATE
    }
}
