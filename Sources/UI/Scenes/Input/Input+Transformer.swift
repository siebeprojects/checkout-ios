import Foundation

extension Input {
    class Transformer {
        private init() {}
    }
}

extension Input.Transformer {
    /// Transform `PaymentNetwork` to `Input.Network`
    static func transform(paymentNetwork: PaymentNetwork) -> Input.Network {
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

        // Switch rule
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
    private static func transform(inputElement: InputElement, translateUsing translator: TranslationProvider) -> InputField & CellRepresentable {
        switch (inputElement.name, inputElement.inputElementType) {
        case ("number", .some(.numeric)):
            return Input.AccountNumberInputField(from: inputElement, translator: translator)
        case ("holderName", .some(.string)):
            return Input.HolderNameInputField(from: inputElement, translator: translator)
        default:
            return Input.GenericInputField(from: inputElement, translator: translator)
        }
    }
}
