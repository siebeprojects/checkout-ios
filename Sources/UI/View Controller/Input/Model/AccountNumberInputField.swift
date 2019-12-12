import Foundation

final class AccountNumberInputField {
    let inputElement: InputElement
    let translator: TranslationProvider
    
    init(from inputElement: InputElement, translator: TranslationProvider) {
        self.inputElement = inputElement
        self.translator = translator
    }
}

extension AccountNumberInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension AccountNumberInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .creditCardNumber }
}
#endif
