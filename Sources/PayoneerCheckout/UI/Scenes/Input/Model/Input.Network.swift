// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking

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

        var operationType: String {
            switch apiModel {
            case .account(let account): return account.operationType
            case .network(let network): return network.operationType
            case .preset(let presetAccount): return presetAccount.operationType
            }
        }

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
        case preset(Networking.PresetAccount)
    }
}

extension Input.Network.APIModel {
    var links: [String: URL]? {
        switch self {
        case .account(let account): return account.links
        case .network(let network): return network.links
        case .preset(let presetAccount): return presetAccount.links
        }
    }

    var operationType: String {
        switch self {
        case .account(let account): return account.operationType
        case .network(let network): return network.operationType
        case .preset(let presetAccount): return presetAccount.operationType
        }
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
        let inputSections: Set<InputSection>
        let submitButton: Input.Field.Button?

        init(networkLabel: String, maskedAccountLabel: String?, logo: UIImage?, inputSections: Set<InputSection>, submitButton: Input.Field.Button?) {
            self.networkLabel = networkLabel
            self.maskedAccountLabel = maskedAccountLabel
            self.logo = logo
            self.inputSections = inputSections
            self.submitButton = submitButton
        }
    }
}

// MARK: - InputSection

extension Input.Network.UIModel {
    /// Section with input fields
    class InputSection {
        let category: InputFieldCategory
        let inputFields: [InputField]

        init(category: InputFieldCategory, inputFields: [InputField]) {
            self.category = category
            self.inputFields = inputFields
        }
    }
}

extension Input.Network.UIModel.InputSection: Hashable, Equatable {
    static func == (lhs: Input.Network.UIModel.InputSection, rhs: Input.Network.UIModel.InputSection) -> Bool {
        guard lhs.category == rhs.category else { return false }
        return lhs.inputFields.elementsEqual(rhs.inputFields) { $0.id == $1.id }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(category)

        for inputField in inputFields {
            hasher.combine(inputField.id)
        }
    }
}

extension Set where Self.Element == Input.Network.UIModel.InputSection {
    subscript(category: Input.Network.UIModel.InputSection.InputFieldCategory) -> Self.Element? {
        return first { $0.category == category }
    }
}

// MARK: InputSection.InputFieldCategory

extension Input.Network.UIModel.InputSection {
    enum InputFieldCategory: Hashable {
        case inputElements
        case registration
        case extraElements(at: VerticalPosition)
    }
}

extension Input.Network.UIModel.InputSection.InputFieldCategory {
    /// Vertical position for extra elements
    enum VerticalPosition {
        case top, bottom
    }
}
