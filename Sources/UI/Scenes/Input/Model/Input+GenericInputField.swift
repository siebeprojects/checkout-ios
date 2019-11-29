import Foundation

extension Input {
    /// Generic input field model that is used for all `localizableInputElements` that doesn't have explict type (e.g. `AccountNumberInputField`)
    final class GenericInputField {
        let inputElement: InputElement
        let translator: TranslationProvider
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider) {
            self.inputElement = inputElement
            self.translator = translator
        }
    }
}


extension Input.GenericInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension Input.GenericInputField: CellRepresentable, DefinesKeyboardStyle {}
#endif
