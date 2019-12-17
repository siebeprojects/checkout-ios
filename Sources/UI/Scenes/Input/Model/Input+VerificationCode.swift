import Foundation

// MARK: Protocol

protocol VerificationCodeTranslationKeySuffixer: class {
    /// Generic / specific key for placeholder translation without dot (e.g. `generic`)
    var suffixKey: String { get }
}

// MARK: - VerificationCodeField

extension Input {
    final class VerificationCodeField {
        let inputElement: InputElement
        let translator: TranslationProvider
        let validationRule: Validation.Rule?
        var validationErrorText: String?
        
        var value: String?
        weak var keySuffixer: VerificationCodeTranslationKeySuffixer?
        
        init(from inputElement: InputElement, translator: TranslationProvider, validationRule: Validation.Rule?) {
            self.inputElement = inputElement
            self.translator = translator
            self.validationRule = validationRule
        }
    }
}

extension Input.VerificationCodeField: TextInputField {
    var placeholder: String {
        let key: String
        
        if let suffix = keySuffixer?.suffixKey {
            key = translationPrefix + suffix + ".placeholder"
        } else {
            let error = InternalError(description: "keySuffixer is not set, it's not an intended behaviour, programmatic error")
            error.log()
            
            key = translationPrefix + "placeholder"
        }
        
        return translator.translation(forKey: key)
    }
}

extension Input.VerificationCodeField: Validatable {
    func localize(error: Input.Validation.ValidationError) -> String {
        switch error {
        case .invalidValue, .incorrectLength: return translator.translation(forKey: "error.INVALID_VERIFICATION_CODE")
        case .missingValue: return translator.translation(forKey: "error.MISSING_VERIFICATION_CODE")
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.VerificationCodeField: CellRepresentable, DefinesKeyboardStyle {}
#endif
