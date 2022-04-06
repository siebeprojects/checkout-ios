// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

extension Input.ModelTransformer {
    class InputElementsTransformer {}
}

extension Input.ModelTransformer.InputElementsTransformer {
    private typealias Constant = Input.ModelTransformer.Constant
    private typealias ExpirationDateManager = Input.ModelTransformer.ExpirationDateManager

    /// Used as input for `createInputFields(for:)` method
    struct TransformableModel {
        var inputElements: [InputElement]
        var networkCode: String
        var paymentMethod: String?
        var translator: TranslationProvider
    }

    func createInputFields(for model: TransformableModel) -> [CellRepresentable & InputField] {
        // Get validation rules
        let validationProvider: Input.Field.Validation.Provider?

        do {
            validationProvider = try .init()
        } catch {
            if let internalError = error as? InternalError {
                internalError.log()
            } else {
                let getRulesError = InternalError(description: "Failed to get validation rules: %@", objects: error)
                getRulesError.log()
            }
            validationProvider = nil
        }

        // Transform input fields
        var inputFields = model.inputElements.compactMap { inputElement -> (InputField & CellRepresentable)? in
            for ignored in Constant.ignoredFields {
                if model.networkCode == ignored.networkCode && inputElement.name == ignored.inputElementName { return nil }
            }

            let validationRule = validationProvider?.getRule(forNetworkCode: model.networkCode, withInputElementName: inputElement.name)
            return transform(inputElement: inputElement, translateUsing: model.translator, validationRule: validationRule, paymentMethod: model.paymentMethod, networkCode: model.networkCode)
        }

        let transformationResult = ExpirationDateManager().removeExpiryFields(in: inputFields)

        // If fields have expiry month and year, replace them with expiry date
        if transformationResult.hadExpirationDate, let expiryDateElementIndex = transformationResult.removedIndexes.first {
            inputFields = transformationResult.fieldsWithoutDateElements
            let expiryDate = Input.Field.ExpiryDate(translator: model.translator)
            inputFields.insert(expiryDate, at: expiryDateElementIndex)
        }

        return inputFields
    }

    /// Transform `InputElement` to `InputField`
    private func transform(inputElement: InputElement, translateUsing translator: TranslationProvider, validationRule: Input.Field.Validation.Rule?, paymentMethod: String?, networkCode: String) -> InputField & CellRepresentable {
        switch inputElement.name {
        case "number":
            return Input.Field.AccountNumber(from: inputElement, translator: translator, validationRule: validationRule, paymentMethod: paymentMethod)
        case "iban":
            return Input.Field.IBAN(from: inputElement, translator: translator, validationRule: validationRule)
        case "holderName":
            return Input.Field.HolderName(from: inputElement, translator: translator, validationRule: validationRule)
        case "verificationCode":
            return Input.Field.VerificationCode(from: inputElement, networkCode: networkCode, translator: translator, validationRule: validationRule)
        case "bankCode":
            return Input.Field.BankCode(from: inputElement, translator: translator, validationRule: validationRule)
        case "bic":
            return Input.Field.BIC(from: inputElement, translator: translator, validationRule: validationRule)
        default:
            return Input.Field.Generic(from: inputElement, translator: translator, validationRule: validationRule)
        }
    }
}
