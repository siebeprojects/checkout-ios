import Foundation

final class HolderNameInputField {
    let inputElement: InputElement
    let translator: TranslationProvider
    var value: String?
    
    init(from inputElement: InputElement, translator: TranslationProvider) {
        self.inputElement = inputElement
        self.translator = translator
    }
}

extension HolderNameInputField: TextInputField {}

#if canImport(UIKit)
import UIKit

extension HolderNameInputField: CellRepresentable, DefinesKeyboardStyle {
    var contentType: UITextContentType? { return .name }
    var autocapitalizationType: UITextAutocapitalizationType { .words }
}
#endif
