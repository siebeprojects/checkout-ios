import Foundation

extension Input {
    class ViewRepresentableFactory {
        let translator: TranslationProvider
        
        init(translator: TranslationProvider) {
            self.translator = translator
        }
    }
}

extension Input.ViewRepresentableFactory {
    func make(from inputElements: [InputElement]) -> [InputField & CellRepresentable] {
        var fields = [InputField & CellRepresentable]()
        for inputElement in inputElements {
            let newField = make(from: inputElement)
            fields.append(newField)
        }
        
        return fields
    }
    
    private func make(from inputElement: InputElement) -> InputField & CellRepresentable {
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
