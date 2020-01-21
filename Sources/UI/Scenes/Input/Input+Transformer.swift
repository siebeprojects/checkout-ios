import Foundation

extension Input {
    class Transformer {
        fileprivate(set) var verificationCodeFields = [Input.VerificationCodeField]()
        
        init() {}
    }
}

extension Input.Transformer {
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
        
        // Input fields
        let inputElements = paymentNetwork.applicableNetwork.localizedInputElements ?? [InputElement]()
        let inputFields = inputElements.map {
            transform(inputElement: $0, translateUsing: paymentNetwork.translation)
        }

        // SmartSwitch rule
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
    
    /// Transform `InputElement` to `InputField`
    private func transform(inputElement: InputElement, translateUsing translator: TranslationProvider) -> InputField & CellRepresentable {
        switch (inputElement.name, inputElement.inputElementType) {
        case ("number", .some(.numeric)):
            return Input.AccountNumberInputField(from: inputElement, translator: translator)
        case ("holderName", .some(.string)):
            return Input.HolderNameInputField(from: inputElement, translator: translator)
        case ("verificationCode", .some(.integer)):
            let field = Input.VerificationCodeField(from: inputElement, translator: translator)
            verificationCodeFields.append(field)
            return field
        default:
            return Input.GenericInputField(from: inputElement, translator: translator)
        }
    }
}
