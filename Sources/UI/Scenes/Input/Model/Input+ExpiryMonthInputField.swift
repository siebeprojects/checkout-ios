import Foundation

extension Input {
    final class ExpiryMonthInputField {
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

extension Input.ExpiryMonthInputField: Validatable {
    func localize(error: Input.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_EXPIRY_MONTH")
        case .missingValue: return translator.translation(forKey: "error.MISSING_EXPIRY_MONTH")
        }
    }
}

extension Input.ExpiryMonthInputField: SelectInputField {}

#if canImport(UIKit)
import UIKit

extension Input.ExpiryMonthInputField: CellRepresentable, DefinesKeyboardStyle {
    var keyboardType: UIKeyboardType {
        return .numberPad
    }
}
#endif
