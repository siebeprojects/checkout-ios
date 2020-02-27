import Foundation
import UIKit

extension Input.Field {
    class Transformer {
        /// Transformed verification code fields.
        /// - Note: we need it to set a placholder suffix delegate after transformation
        fileprivate(set) var verificationCodeFields = [Input.Field.VerificationCode]()
        fileprivate var expiryMonth: ExpiryMonth?
        fileprivate var expiryYear: ExpiryYear?
        
        init() {}
    }
}

extension Input.Field.Transformer {
    private struct Constant {
        static var ignoredFields: [IgnoredFields] { [
            .init(networkCode: "SEPADD", inputElementName: "bic")
        ] }
        
        static var registrationCheckboxLocalizationKey: String { "autoRegistrationLabel" }
        static var recurrenceCheckboxLocalizationKey: String { "allowRecurrenceLabel" }
    }
    
    func transform(registeredAccount: RegisteredAccount) -> Input.Network {
        let logoData = registeredAccount.logo?.value
        let inputElements = registeredAccount.apiModel.localizedInputElements ?? [InputElement]()
        
        let modelToTransform = TransformableModel(logoData: logoData, inputElements: inputElements, networkCode: registeredAccount.apiModel.code, networkMethod: nil, label: registeredAccount.networkLabel, translator: registeredAccount.translation, registrationRequirement: nil, recurrenceRequirement: nil)
        
        return transform(modelToTransform)
    }
    
    func transform(paymentNetwork: PaymentNetwork) -> Input.Network {
        let logoData: Data?
        
        // FIXME: Use refactored method
        // Was loading started? Was loading completed? Was it completed successfully?
        if case let .some(.loaded(.success(imageData))) = paymentNetwork.logo {
            logoData = imageData
        } else {
            logoData = nil
        }
        
        let inputElements = paymentNetwork.applicableNetwork.localizedInputElements ?? [InputElement]()
        
        let modelToTransform = TransformableModel(logoData: logoData, inputElements: inputElements, networkCode: paymentNetwork.applicableNetwork.code, networkMethod: paymentNetwork.applicableNetwork.method, label: paymentNetwork.label, translator: paymentNetwork.translation, registrationRequirement: paymentNetwork.applicableNetwork.registrationRequirement, recurrenceRequirement: paymentNetwork.applicableNetwork.recurrenceRequirement)
        
        return transform(modelToTransform)
    }
    
    /// Used as input for `transform(:)` method
    private struct TransformableModel {
        var logoData: Data?
        var inputElements: [InputElement]
        var networkCode: String
        var networkMethod: String?
        var label: String
        var translator: TranslationProvider
        var registrationRequirement: ApplicableNetwork.Requirement?
        var recurrenceRequirement: ApplicableNetwork.Requirement?
    }
    
    /// Transform model to `Input.Network`
    private func transform(_ model: TransformableModel) -> Input.Network {
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
        let inputFields = model.inputElements.compactMap { inputElement -> (InputField & CellRepresentable)? in
            for ignored in Constant.ignoredFields {
                if model.networkCode == ignored.networkCode && inputElement.name == ignored.inputElementName { return nil }
            }
            
            let validationRule = validationProvider?.getRule(forNetworkCode: model.networkCode, withInputElementName: inputElement.name)
            
            return transform(inputElement: inputElement, translateUsing: model.translator, validationRule: validationRule, networkMethod: model.networkMethod)
        }
        
        let registrationCheckbox = checkbox(translationKey: Constant.registrationCheckboxLocalizationKey, requirement: model.registrationRequirement, translator: model.translator)
        let recurrenceCheckbox = checkbox(translationKey: Constant.recurrenceCheckboxLocalizationKey, requirement: model.recurrenceRequirement, translator: model.translator)
        
        // Link month and year fields
        expiryYear?.expiryMonthField = expiryMonth
        expiryMonth?.expiryYearField = expiryYear

        // Get SmartSwitch rules for a network
        let switchRule: Input.SmartSwitch.Rule?
        do {
            let switchProvider = Input.SmartSwitch.Provider()
            switchRule = try switchProvider.getRules().first(withCode: model.networkCode)
        } catch {
            let internalError = InternalError(description: "Unable to decode smart switch rules: %@", objects: error)
            internalError.log()
            
            switchRule = nil
        }
        
        return .init(networkCode: model.networkCode, translator: model.translator, label: model.label, logoData: model.logoData, inputFields: inputFields, autoRegistration: registrationCheckbox, allowRecurrence: recurrenceCheckbox, switchRule: switchRule)
    }
    
    private func checkbox(translationKey: String, requirement: ApplicableNetwork.Requirement?, translator: TranslationProvider) -> Input.Field.Checkbox {
        let isOn: Bool
        var isEnabled: Bool = true
        var isHidden: Bool = false
        
        switch requirement {
        case .OPTIONAL: isOn = false
        case .OPTIONAL_PRESELECTED: isOn = true
        case .FORCED:
            isOn = true
            isHidden = true
        case .FORCED_DISPLAYED:
            isOn = true
            isEnabled = false
        default:
            isOn = false
            isHidden = true
        }
        
        return Input.Field.Checkbox(isOn: isOn, isEnabled: isEnabled, isHidden: isHidden, translationKey: translationKey, translator: translator)
    }
    
    /// Transform `InputElement` to `InputField`
    private func transform(inputElement: InputElement, translateUsing translator: TranslationProvider, validationRule: Input.Field.Validation.Rule?, networkMethod: String?) -> InputField & CellRepresentable {
        switch inputElement.name {
        case "number":
            return Input.Field.AccountNumber(from: inputElement, translator: translator, validationRule: validationRule, networkMethod: networkMethod)
        case "iban":
            return Input.Field.IBAN(from: inputElement, translator: translator, validationRule: validationRule)
        case "holderName":
            return Input.Field.HolderName(from: inputElement, translator: translator, validationRule: validationRule)
        case "verificationCode":
            let field = Input.Field.VerificationCode(from: inputElement, translator: translator, validationRule: validationRule)
            verificationCodeFields.append(field)
            return field
        case "expiryMonth":
            let field = Input.Field.ExpiryMonth(from: inputElement, translator: translator)
            self.expiryMonth = field
            return field
        case "expiryYear":
            let field = Input.Field.ExpiryYear(from: inputElement, translator: translator)
            self.expiryYear = field
            return field
        case "bankCode":
            return Input.Field.BankCode(from: inputElement, translator: translator, validationRule: validationRule)
        case "bic":
            return Input.Field.BIC(from: inputElement, translator: translator, validationRule: validationRule)
        default:
            return Input.Field.Generic(from: inputElement, translator: translator, validationRule: validationRule)
        }
    }
}

extension Input.Field.Transformer {
    fileprivate struct IgnoredFields {
        let networkCode: String
        let inputElementName: String
    }
}
