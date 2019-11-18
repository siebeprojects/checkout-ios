import Foundation

protocol InputField {
    var inputElement: InputElement { get }
    var translator: TranslationProvider { get }
    
    var name: String { get }
    var label: String { get }
}

extension InputField {
    var name: String { inputElement.name }
    var label: String {
        translator.translation(forKey: translationPrefix + "label")
    }
    
    private var translationPrefix: String { "account." + name + "." }
}
