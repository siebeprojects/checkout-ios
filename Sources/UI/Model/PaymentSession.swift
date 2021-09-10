// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

final class PaymentSession {
    enum Operation: String {
        case CHARGE, UPDATE
    }

    let networks: [PaymentNetwork]
    let registeredAccounts: [RegisteredAccount]?
    let context: PaymentContext

    init(networks: [TranslatedModel<ApplicableNetwork>], accounts: [TranslatedModel<AccountRegistration>]?, context: PaymentContext) {
        self.context = context

        let buttonLocalizationKey = "button.operation." + context.listOperationType.rawValue.uppercased() + ".label"

        self.networks = networks.map {
            .init(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator)
        }

        /// Defined in https://optile.atlassian.net/browse/PCX-2012
        let isDeletable: Bool = {
            switch context.listOperationType {
            case .UPDATE:
                return (context.allowDelete == nil) || (context.allowDelete == true)
            case .CHARGE:
                return context.allowDelete == true
            }
        }()

        self.registeredAccounts = accounts?.map {
            RegisteredAccount(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator, isDeletable: isDeletable)
        }
    }
}
