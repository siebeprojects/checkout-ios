import Foundation

extension Input.Field {
    final class IBAN: InputElementModel {
        let inputElement: InputElement
        let translator: TranslationProvider
        let validationRule: Validation.Rule?
        var validationErrorText: String?
        let patternFormatter: InputPatternFormatter?

        var value: String = ""

        init(from inputElement: InputElement, translator: TranslationProvider, validationRule: Validation.Rule?) {
            self.inputElement = inputElement
            self.translator = translator
            self.validationRule = validationRule

            // Pattern formatter
            let maxLength = validationRule?.maxLength ?? 34
            let patternFormatter = InputPatternFormatter(maxStringLength: maxLength, separator: " ", every: 4)
            patternFormatter.inputModifiers = [UppercaseInputModifier()]
            self.patternFormatter = patternFormatter
        }
    }
}

extension Input.Field.IBAN: Validatable {
    func localize(error: Input.Field.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_IBAN")
        case .missingValue: return translator.translation(forKey: "error.MISSING_IBAN")
        }
    }

    var isPassedCustomValidation: Bool {
        return Input.Field.Validation.IBAN.isValid(iban: value)
    }
}

#if canImport(UIKit)
import UIKit

extension Input.Field.IBAN: CellRepresentable, DefinesKeyboardStyle {
    var keyboardType: UIKeyboardType { .asciiCapable }
    var autocapitalizationType: UITextAutocapitalizationType { .allCharacters }
}

extension Input.Field.IBAN: TextInputField {
    var allowedCharacters: CharacterSet? { return .alphanumerics }
}
#endif
