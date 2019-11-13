import Foundation

#if canImport(UIKit)
import UIKit
#endif

final class InputField {
    let name: String
    let label: String
    let placeholder: String
    let type: InputElement.InputElementType
    
    #if canImport(UIKit)
    let contentType: UITextContentType?
    #endif
    
    init(from inputElement: InputElement, localizeUsing localizer: TranslationProvider) {
        let keyPrefix = "account." + inputElement.name + "."
        
        #if canImport(UIKit)
        switch inputElement.name {
        case "holderName": contentType = .some(.name)
        case "number": contentType = .some(.creditCardNumber)
        default: contentType = nil
        }
        #endif
        
        self.name = inputElement.name
        self.label = localizer.translation(forKey: keyPrefix + "label")
        self.placeholder = localizer.translation(forKey: keyPrefix + "placeholder")
        self.type = inputElement.inputElementType ?? .string
    }
    
    enum ContentType {
        case creditCardNumber
        case name
    }
}
