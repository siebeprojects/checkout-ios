import Foundation

/// UI model for all text input fields
protocol TextInputField: InputField {
    var placeholder: String { get }
    var maxInputLength: Int? { get }
    var formatProcessor: TextFormatProcessor? { get }
}

extension TextInputField {
    var formatProcessor: TextFormatProcessor? { nil }
}

extension TextInputField {
    var placeholder: String {
        translator.translation(forKey: translationPrefix + "placeholder")
    }

    var translationPrefix: String { "account." + name + "." }
}
