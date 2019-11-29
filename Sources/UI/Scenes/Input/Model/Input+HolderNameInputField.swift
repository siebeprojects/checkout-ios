import Foundation

extension Input {
    final class HolderNameInputField {
        let inputElement: InputElement
        let translator: TranslationProvider
        var value: String?
        
        init(from inputElement: InputElement, translator: TranslationProvider) {
            self.inputElement = inputElement
            self.translator = translator
        }
    }
}

extension Input.HolderNameInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension Input.HolderNameInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .name }
    var autocapitalizationType: UITextAutocapitalizationType { .words }
}
#endif
