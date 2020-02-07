import Foundation

/// Generic UI model for input element
protocol InputField: class {
    var inputElement: InputElement { get }
    var translator: TranslationProvider { get }
    
    var name: String { get }
    var label: String { get }
    var value: String { get set }
}

extension InputField {
    var name: String { inputElement.name }
    var label: String {
        translator.translation(forKey: translationPrefix + "label")
    }
    
    private var translationPrefix: String { "account." + name + "." }
}