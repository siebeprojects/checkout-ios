import Foundation

extension Input.Field {
    final class ExpiryDate {
        let translator: TranslationProvider
        var validationErrorText: String?

        let patternFormatter: InputPatternFormatter? = {
            let formatter = InputPatternFormatter(textPattern: "## / ##")
            formatter.shouldAddTrailingPattern = true
            formatter.inputModifiers = [ExpirationDateInputModifier()]
            return formatter
        }()
        
        var value: String = ""

        init(translator: TranslationProvider) {
            self.translator = translator
        }
    }
}

//extension Input.Field.ExpiryDate: Validatable {
//    func localize(error: Input.Field.Validation.ValidationError) -> String {
//        switch error {
//        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_EXPIRY_MONTH")
//        case .missingValue: return translator.translation(forKey: "error.MISSING_EXPIRY_MONTH")
//        }
//    }
//
//    var isPassedCustomValidation: Bool {
//        guard let expiryYear = expiryYearField?.value else {
//            // Don't check if year is not filled, that have to be done when is filled option is used.
//            return true
//        }
//
//        let validationResult = Input.Field.Validation.ExpiryDate.isInFuture(expiryMonth: value, expiryYear: expiryYear) ?? false
//        return validationResult
//    }
//}

extension Input.Field.ExpiryDate: TextInputField {
    var maxInputLength: Int? { 4 }
    var name: String { "expirationDate" }
    var label: String { translator.translation(forKey: LocalTranslation.expirationDateTitle.rawValue) }
    var placeholder: String { translator.translation(forKey: LocalTranslation.expirationDatePlaceholder.rawValue) }
}

#if canImport(UIKit)
import UIKit

extension Input.Field.ExpiryDate: CellRepresentable, DefinesKeyboardStyle {
    var keyboardType: UIKeyboardType {
        return .numberPad
    }
}
#endif
