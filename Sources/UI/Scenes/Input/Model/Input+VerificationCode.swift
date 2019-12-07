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
        weak var keySuffixer: VerificationCodeTranslationKeySuffixer?
        
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider) {
            self.inputElement = inputElement
            self.translator = translator
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

#if canImport(UIKit)
import UIKit

extension Input.VerificationCodeField: CellRepresentable, DefinesKeyboardStyle {}
#endif
