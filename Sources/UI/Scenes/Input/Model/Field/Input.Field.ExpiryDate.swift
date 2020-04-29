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

extension Input.Field.ExpiryDate: Validatable {
    var validationRule: Input.Field.Validation.Rule? { nil }
    
    func localize(error: Input.Field.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_EXPIRY_DATE")
        case .missingValue: return translator.translation(forKey: "error.MISSING_EXPIRY_DATE")
        }
    }

    var isPassedCustomValidation: Bool {
        guard value.count == 4 else {
            return false
        }
        
        let month = String(value.prefix(2))
        let year = String("20" + value.suffix(2))

        let validationResult = Input.Field.Validation.ExpiryDate.isInFuture(expiryMonth: month, expiryYear: year) ?? false
        return validationResult
    }
}

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
