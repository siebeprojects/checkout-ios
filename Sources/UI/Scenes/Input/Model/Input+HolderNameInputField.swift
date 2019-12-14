import Foundation

extension Input {
    final class HolderNameInputField {
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

extension Input.HolderNameInputField: TextInputField {}

extension Input.HolderNameInputField: Validatable {
    func localize(error: Input.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue: return translator.translation(forKey: "error.INVALID_HOLDER_NAME")
        case .missingValue: return translator.translation(forKey: "error.MISSING_HOLDER_NAME")
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.HolderNameInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .name }
    var autocapitalizationType: UITextAutocapitalizationType { .words }
}
#endif
