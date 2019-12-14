import Foundation

extension Input {
    final class AccountNumberInputField {
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

extension Input.AccountNumberInputField: TextInputField {}

extension Input.AccountNumberInputField: Validatable {
    func localize(error: Input.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue: return translator.translation(forKey: "error.INVALID_ACCOUNT_NUMBER")
        case .missingValue: return translator.translation(forKey: "error.MISSING_ACCOUNT_NUMBER")
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.AccountNumberInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .creditCardNumber }
}
#endif
