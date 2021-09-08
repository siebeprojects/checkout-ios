// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input {
    class Network {
        let operationURL: URL

        /// Indicates payment method this network belongs to.
        let paymentMethod: String?

        let translation: TranslationProvider
        let switchRule: SmartSwitch.Rule?
        let networkCode: String

        let uiModel: UIModel

        let apiModel: APIModel

        let isDeletable: Bool

        init(apiModel: APIModel, operationURL: URL, paymentMethod: String?, networkCode: String, translator: TranslationProvider, switchRule: SmartSwitch.Rule?, uiModel: UIModel, isDeletable: Bool) {
            self.apiModel = apiModel
            self.operationURL = operationURL
            self.paymentMethod = paymentMethod
            self.networkCode = networkCode
            self.translation = translator
            self.switchRule = switchRule
            self.uiModel = uiModel
            self.isDeletable = isDeletable
        }
    }
}

extension Input.Network {
    enum APIModel {
        case account(AccountRegistration)
        case network(ApplicableNetwork)
    }
}

extension Input.Network: Equatable {
    static func == (lhs: Input.Network, rhs: Input.Network) -> Bool {
        return lhs.networkCode == rhs.networkCode
    }
}

// MARK: - UIModel

extension Input.Network {
    class UIModel {
        let networkLabel: String
        let maskedAccountLabel: String?
        let logo: UIImage?
        let inputFieldsByCategory: [InputFieldCategory: [InputField]]
        let submitButton: Input.Field.Button?

        init(networkLabel: String, maskedAccountLabel: String?, logo: UIImage?, inputFieldsByCategory: [InputFieldCategory: [InputField]], submitButton: Input.Field.Button?) {
            self.networkLabel = networkLabel
            self.maskedAccountLabel = maskedAccountLabel
            self.logo = logo
            self.inputFieldsByCategory = inputFieldsByCategory
            self.submitButton = submitButton
        }
    }
}

// MARK: UIModel.InputFieldCategory

extension Input.Network.UIModel {
    enum InputFieldCategory: Hashable {
        case account
        case registration
        case extraElements(at: VerticalPosition)
    }
}

extension Input.Network.UIModel.InputFieldCategory {
    enum VerticalPosition {
        case top, bottom
    }
}
