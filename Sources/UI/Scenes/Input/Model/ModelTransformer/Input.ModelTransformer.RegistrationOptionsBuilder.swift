// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ModelTransformer {
    /// Builder responsible for making UI models from registration options.
    class RegistrationOptionsBuilder {
        let translator: TranslationProvider
        let operationType: String?

        init(translator: TranslationProvider, operationType: String?) {
            self.translator = translator
            self.operationType = operationType
        }
    }
}

extension Input.ModelTransformer.RegistrationOptionsBuilder {
    func createInternalModel(from registrationOption: RegistrationOption) -> InputField {
        if operationType == "UPDATE" {
            return createInternalModel(forUpdateFlowFrom: registrationOption)
        }

        let isOn: Bool

        switch registrationOption.requirement {
        case .OPTIONAL: isOn = false
        case .OPTIONAL_PRESELECTED: isOn = true
        case .FORCED_DISPLAYED:
            let translationKey = localizationKey(for: registrationOption)
            return Input.Field.Label(label: translator.translation(forKey: translationKey), name: registrationOption.type.name, value: true.stringValue)
        case .FORCED:
            return Input.Field.Hidden(name: registrationOption.type.name, value: true.stringValue)
        case .NONE:
            return Input.Field.Hidden(name: registrationOption.type.name, value: false.stringValue)
        }

        let label: String = translator.translation(forKey: localizationKey(for: registrationOption))
        return Input.Field.Checkbox(name: registrationOption.type.name, isOn: isOn, label: label)
    }

    /// Make hidden fields based on registration options.
    ///
    /// Framework shouldn't show any registration options checkboxes for `UPDATE` operation type.
    /// - SeeAlso: [PCX-1396](https://optile.atlassian.net/browse/PCX-1396)
    private func createInternalModel(forUpdateFlowFrom registrationOption: RegistrationOption) -> InputField {
        switch registrationOption.requirement {
        case .NONE: return Input.Field.Hidden(name: registrationOption.type.name, value: false.stringValue)
        default: return Input.Field.Hidden(name: registrationOption.type.name, value: true.stringValue)
        }
    }

    /// Localization key rules are declared in [PCX-728](https://optile.atlassian.net/browse/PCX-728).
    /// - Returns: localization key, `nil` if requirement is `NONE`
    private func localizationKey(for registrationOption: RegistrationOption) -> String {
        var localizationKey = "networks."

        switch registrationOption.type {
        case .registration: localizationKey += "registration."
        case .recurrence: localizationKey += "recurrence."
        }

        switch registrationOption.requirement {
        case .OPTIONAL, .OPTIONAL_PRESELECTED: localizationKey += "optional."
        case .FORCED, .FORCED_DISPLAYED: localizationKey += "forced."
        case .NONE:
            assertionFailure("Programmatic error, shouldn't call that function with NONE requirement type")
            return String()
        }

        localizationKey += "label"

        return localizationKey
    }
}

extension Input.ModelTransformer.RegistrationOptionsBuilder {
    struct RegistrationOption {
        let type: CheckboxType
        let requirement: ApplicableNetwork.Requirement

        init(type: RegistrationOption.CheckboxType, requirement: ApplicableNetwork.Requirement?) {
            self.type = type
            self.requirement = requirement ?? .NONE
        }
    }
}

extension Input.ModelTransformer.RegistrationOptionsBuilder.RegistrationOption {
    enum CheckboxType {
        case recurrence
        case registration

        var name: String {
            switch self {
            case .recurrence: return Input.Field.Checkbox.Constant.allowRecurrence
            case .registration: return Input.Field.Checkbox.Constant.allowRegistration
            }
        }
    }
}
