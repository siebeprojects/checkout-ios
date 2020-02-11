import Foundation

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
    
    /// Transform `PaymentNetwork` to `Input.Network`
    func transform(paymentNetwork: PaymentNetwork) -> Input.Network {
        // Logo
        let logoData: Data?
        
        // Was loading started? Was loading completed? Was it completed successfully?
        if case let .some(.loaded(.success(imageData))) = paymentNetwork.logo {
            logoData = imageData
        } else {
            logoData = nil
        }
        
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
        let inputElements = paymentNetwork.applicableNetwork.localizedInputElements ?? [InputElement]()
        var inputFields = inputElements.compactMap { inputElement -> (InputField & CellRepresentable)? in
            for ignored in Constant.ignoredFields {
                if paymentNetwork.applicableNetwork.code == ignored.networkCode && inputElement.name == ignored.inputElementName { return nil }
            }
            
            let validationRule = validationProvider?.getRule(forNetworkCode: paymentNetwork.applicableNetwork.code, withInputElementName: inputElement.name)
            
            return transform(inputElement: inputElement, translateUsing: paymentNetwork.translation, validationRule: validationRule, networkMethod: paymentNetwork.applicableNetwork.method)
        }
        
        addCheckbox(translationKey: Constant.registrationCheckboxLocalizationKey, requirement: paymentNetwork.applicableNetwork.registrationRequirement, translator: paymentNetwork.translation, to: &inputFields)
        addCheckbox(translationKey: Constant.recurrenceCheckboxLocalizationKey, requirement: paymentNetwork.applicableNetwork.recurrenceRequirement, translator: paymentNetwork.translation, to: &inputFields)
        
        // Link month and year fields
        expiryYear?.expiryMonthField = expiryMonth
        expiryMonth?.expiryYearField = expiryYear

        // Get SmartSwitch rules for a network
        let switchRule: Input.SmartSwitch.Rule?
        do {
            let switchProvider = Input.SmartSwitch.Provider()
            switchRule = try switchProvider.getRules().first(withCode: paymentNetwork.applicableNetwork.code)
        } catch {
            let internalError = InternalError(description: "Unable to decode smart switch rules: %@", objects: error)
            internalError.log()
            
            switchRule = nil
        }
        
        return .init(paymentNetwork: paymentNetwork, label: paymentNetwork.label, logoData: logoData, inputFields: inputFields, switchRule: switchRule)
    }
    
    private func addCheckbox(translationKey: String, requirement: ApplicableNetwork.Requirement?, translator: TranslationProvider, to inputFields: inout [CellRepresentable & InputField]) {
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
        default: return
        }
        
        inputFields += [Input.Field.Checkbox(isOn: isOn, isEnabled: isEnabled, isHidden: isHidden, translationKey: translationKey, translator: translator)]
    }
    
    /// Transform `InputElement` to `InputField`
    private func transform(inputElement: InputElement, translateUsing translator: TranslationProvider, validationRule: Input.Field.Validation.Rule?, networkMethod: String) -> InputField & CellRepresentable {
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
