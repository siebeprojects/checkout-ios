import Foundation

extension Input {
    final class ExpiryYearInputField {
        let inputElement: InputElement
        let translator: TranslationProvider
        var validationErrorText: String?
        
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider) {
            self.inputElement = inputElement
            self.translator = translator
        }
    }
}

extension Input.ExpiryYearInputField: Validatable {
    func localize(error: Input.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_EXPIRY_YEAR")
        case .missingValue: return translator.translation(forKey: "error.MISSING_EXPIRY_YEAR")
        }
    }
}

extension Input.ExpiryYearInputField: SelectInputField {}

#if canImport(UIKit)
import UIKit

extension Input.ExpiryYearInputField: CellRepresentable, DefinesKeyboardStyle {
    var keyboardType: UIKeyboardType {
        return .numberPad
    }
}
#endif
