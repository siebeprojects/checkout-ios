#if canImport(UIKit)
import UIKit

/// Controls keyboard's appearance
protocol DefinesKeyboardStyle where Self: TextInputField {
    var contentType: UITextContentType? { get }
    var keyboardType: UIKeyboardType { get }
    var autocapitalizationType: UITextAutocapitalizationType { get }
}

extension DefinesKeyboardStyle where Self: TextInputField {
    var contentType: UITextContentType? { nil }
    var keyboardType: UIKeyboardType {
        switch self.inputElement.inputElementType {
        case .some(.numeric): return .numbersAndPunctuation
        case .some(.integer): return .numberPad
        default: return .default
        }
    }
    var autocapitalizationType: UITextAutocapitalizationType { .none }
}
#endif
