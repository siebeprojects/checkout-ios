import Foundation

class ViewRepresentableFactory {
    let translator: TranslationProvider
    
    init(translator: TranslationProvider) {
        self.translator = translator
    }
    
    func make(from inputElements: [InputElement]) -> [ViewRepresentable] {
        var fields = [ViewRepresentable]()
        for inputElement in inputElements {
            let newField = make(from: inputElement)
            fields.append(newField)
        }
        
        return fields
    }
    
    private func make(from inputElement: InputElement) -> ViewRepresentable {
        switch (inputElement.name, inputElement.inputElementType) {
        case ("number", .some(.numeric)):
            return AccountNumberInputField(from: inputElement, translator: translator)
        case ("holderName", .some(.string)):
            return HolderNameInputField(from: inputElement, translator: translator)
        default:
            return GenericInputField(from: inputElement, translator: translator)
        }
    }
}


