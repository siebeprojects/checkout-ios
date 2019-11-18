import Foundation

protocol TextInputField: InputField {
    var placeholder: String { get }
}

extension TextInputField {
    var placeholder: String {
        translator.translation(forKey: translationPrefix + "placeholder")
    }
    
    private var translationPrefix: String { "account." + name + "." }
}
