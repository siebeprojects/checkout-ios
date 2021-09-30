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
        let listOperationType: PaymentSession.Operation

        init(translator: TranslationProvider, listOperationType: PaymentSession.Operation) {
            self.translator = translator
            self.listOperationType = listOperationType
        }
    }
}

extension Input.ModelTransformer.RegistrationOptionsBuilder {
    func createInternalModel(fromRegistration registration: ApplicableNetwork.RegistrationOption, reccurrence: ApplicableNetwork.RegistrationOption) throws -> [InputField] {
        switch listOperationType {
        // That case applies to PRESET flow as well when it will be supported
        case .CHARGE:
            return try createInputFields(forChargeFlowUsingRegistration: registration, recurrence: reccurrence)
        case .UPDATE:
            return try createInputFields(forUpdateFlowUsingRegistration: registration, reccurrence: reccurrence)
        }

    }

    private var localizedRegistrationLabel: NSAttributedString {
        let localizedString: String = translator.translation(forKey: "networks.registration.label")
        return NSAttributedString(string: localizedString)
    }

    private func createInputFields(forChargeFlowUsingRegistration registration: ApplicableNetwork.RegistrationOption, recurrence: ApplicableNetwork.RegistrationOption) throws -> [InputField] {
        switch (registration, recurrence) {
        case (.NONE, .NONE): return [InputField]()
        case (.FORCED, .NONE):
            let registrationField = Input.Field.Hidden(id: .registration, value: true.stringValue)
            return [registrationField]
        case (.FORCED_DISPLAYED, .NONE):
            let registrationField = Input.Field.Label(label: localizedRegistrationLabel, id: .registration, value: true.stringValue)
            return [registrationField]
        case (.FORCED, .FORCED):
            let registrationField = Input.Field.Hidden(id: .registration, value: true.stringValue)
            let recurrenceField = Input.Field.Hidden(id: .recurrence, value: true.stringValue)
            return [registrationField, recurrenceField]
        case (.FORCED_DISPLAYED, .FORCED_DISPLAYED):
            let registrationField = Input.Field.Label(label: localizedRegistrationLabel, id: .registration, value: true.stringValue)
            let recurrenceField = Input.Field.Hidden(id: .recurrence, value: true.stringValue)
            return [registrationField, recurrenceField]
        case (.OPTIONAL, .NONE):
            let registrationField = Input.Field.Checkbox(id: .registration, isOn: false, label: localizedRegistrationLabel)
            return [registrationField]
        case (.OPTIONAL_PRESELECTED, .NONE):
            let registrationField = Input.Field.Checkbox(id: .registration, isOn: true, label: localizedRegistrationLabel)
            return [registrationField]
        case (.OPTIONAL, .OPTIONAL):
            let combinedField = Input.Field.Checkbox(id: .combinedRegistration, isOn: false, label: localizedRegistrationLabel)
            return [combinedField]
        case (.OPTIONAL_PRESELECTED, .OPTIONAL_PRESELECTED):
            let combinedField = Input.Field.Checkbox(id: .combinedRegistration, isOn: true, label: localizedRegistrationLabel)
            return [combinedField]
        default:
            let internalError = InternalError(description: "Unsupported combination of autoRegistration (" + registration.rawValue + ") and allowRecurrence (" + recurrence.rawValue + ") for a charge flow")
            let errorInfo = CustomErrorInfo.createClientSideError(from: internalError)
            throw errorInfo
        }
    }

    /// Make hidden fields based on registration options.
    ///
    /// Framework shouldn't show any registration options checkboxes for `UPDATE` operation type.
    /// - SeeAlso: [PCX-1396](https://optile.atlassian.net/browse/PCX-1396)
    private func createInputFields(forUpdateFlowUsingRegistration registration: ApplicableNetwork.RegistrationOption, reccurrence: ApplicableNetwork.RegistrationOption) throws -> [InputField] {
        var inputFields = [InputField]()

        switch registration {
        case .NONE: inputFields += [Input.Field.Hidden(id: .registration, value: false.stringValue)]
        default: inputFields += [Input.Field.Hidden(id: .registration, value: true.stringValue)]
        }

        switch reccurrence {
        case .NONE: inputFields += [Input.Field.Hidden(id: .recurrence, value: false.stringValue)]
        default: inputFields += [Input.Field.Hidden(id: .recurrence, value: true.stringValue)]
        }

        return inputFields
    }
}
