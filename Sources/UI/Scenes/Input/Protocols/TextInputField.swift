import Foundation

/// UI model for all text input fields
protocol TextInputField: InputField {
    var placeholder: String { get }
    var maxInputLength: Int? { get }
    var patternFormatter: InputPatternFormatter? { get }
}

extension TextInputField {
    var patternFormatter: InputPatternFormatter? { nil }
}

extension TextInputField {
    var placeholder: String {
        translator.translation(forKey: translationPrefix + "placeholder")
    }

    var translationPrefix: String { "account." + name + "." }
}
