import Foundation

/// UI model for all text input fields
protocol TextInputField: InputField {
    var translator: TranslationProvider { get }
    var label: String { get }
    var placeholder: String { get }
    var maxInputLength: Int? { get }
    var patternFormatter: InputPatternFormatter? { get }
    var allowedCharacters: CharacterSet? { get }
}

extension TextInputField {
    var patternFormatter: InputPatternFormatter? { nil }
}

extension TextInputField {
    var placeholder: String {
        translator.translation(forKey: translationPrefix + "placeholder")
    }

    var label: String {
        translator.translation(forKey: translationPrefix + "label")
    }

    var translationPrefix: String { "account." + name + "." }
}
