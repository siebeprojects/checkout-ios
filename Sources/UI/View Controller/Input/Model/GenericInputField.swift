import Foundation


/// Generic input field model that is used for all `localizableInputElements` that doesn't have explict type (e.g. `AccountNumberInputField`)
final class GenericInputField {
    let inputElement: InputElement
    let translator: TranslationProvider
    
    init(from inputElement: InputElement, translator: TranslationProvider) {
        self.inputElement = inputElement
        self.translator = translator
    }
}

extension GenericInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension GenericInputField: CellRepresentable, DefinesKeyboardStyle {}
#endif
