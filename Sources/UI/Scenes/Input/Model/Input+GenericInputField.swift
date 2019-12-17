import Foundation

extension Input {
    /// Generic input field model that is used for all `localizableInputElements` that doesn't have explict type (e.g. `AccountNumberInputField`)
    final class GenericInputField {
        let inputElement: InputElement
        let translator: TranslationProvider
        let validationRule: Validation.Rule?
        var validationErrorText: String?
        
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider, validationRule: Validation.Rule?) {
            self.inputElement = inputElement
            self.translator = translator
            self.validationRule = validationRule
        }
    }
}

extension Input.GenericInputField: TextInputField {}

extension Input.GenericInputField: Validatable {
    // FIXME: How to get localization for a unknown fields?
    func localize(error: Input.Validation.ValidationError) -> String {
        return "<FIXME> No localization"
    }
}

#if canImport(UIKit)
import UIKit

extension Input.GenericInputField: CellRepresentable, DefinesKeyboardStyle {}
#endif
