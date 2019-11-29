import Foundation

extension Input {
    final class AccountNumberInputField {
        let inputElement: InputElement
        let translator: TranslationProvider
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider) {
            self.inputElement = inputElement
            self.translator = translator
        }
    }
}

extension Input.AccountNumberInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension Input.AccountNumberInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .creditCardNumber }
}
#endif
