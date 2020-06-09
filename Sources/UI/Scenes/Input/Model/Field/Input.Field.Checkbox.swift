import Foundation

extension Input.Field {
    final class Checkbox {
        let translationKey: String
        let translator: TranslationProvider

        let name: String
        let isEnabled: Bool
        var isOn: Bool
        var isHidden: Bool
        
        var text: String { translator.translation(forKey: translationKey) }

        init(name: String, isOn: Bool, isEnabled: Bool, isHidden: Bool, translationKey: String, translator: TranslationProvider) {
            self.name = name
            self.translationKey = translationKey
            self.translator = translator
            self.isOn = isOn
            self.isEnabled = isEnabled
            self.isHidden = isHidden
        }
    }
}

extension Input.Field.Checkbox: InputField {
    var value: String {
        get { isOn.stringValue }
        set {
            guard let newBoolean = Bool(stringValue: newValue) else {
                InternalError(description: "Tried to set boolean from unexpected string value: %@", newValue).log()
                return
            }

            isOn = newBoolean
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.Field.Checkbox: CellRepresentable {}
#endif
