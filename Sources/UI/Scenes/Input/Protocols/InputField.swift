import Foundation

/// Generic UI model for input element
protocol InputField: class {
    var translator: TranslationProvider { get }
    
    var name: String { get }
    var isHidden: Bool { get }
    var label: String { get }
    var value: String { get set }
}

extension InputField {
    var label: String {
        translator.translation(forKey: translationPrefix + "label")
    }
    
    var isHidden: Bool { false }
    
    private var translationPrefix: String { "account." + name + "." }
}

extension InputField where Self: InputElementModel {
    var name: String { inputElement.name }
}
