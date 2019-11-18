import Foundation

final class GenericInputField {
    let inputElement: InputElement
    let translator: TranslationProvider
    
    init(from inputElement: InputElement, translator: TranslationProvider) {
        self.inputElement = inputElement
        self.translator = translator
    }
}

extension GenericInputField: TextInputField, ViewRepresentable {}

#if canImport(UIKit)
import UIKit

extension GenericInputField: DefinesKeyboardStyle {}
#endif
