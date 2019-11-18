import Foundation

final class HolderNameInputField {
    let inputElement: InputElement
    let translator: TranslationProvider
    
    init(from inputElement: InputElement, translator: TranslationProvider) {
        self.inputElement = inputElement
        self.translator = translator
    }
}

extension HolderNameInputField: TextInputField, ViewRepresentable {}

#if canImport(UIKit)
import UIKit

extension HolderNameInputField: DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .name }
    var autocapitalizationType: UITextAutocapitalizationType { .words }
}
#endif
