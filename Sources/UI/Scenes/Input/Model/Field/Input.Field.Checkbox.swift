import Foundation

extension Input.Field {
    final class Checkbox {
        struct Constant {
            static var allowRegistration: String { "allowRegistration" }
            static var allowRecurrence: String { "allowRecurrence" }
        }

        let translationKey: String
        let translator: TranslationProvider

        let name: String
        var isOn: Bool
        var isEnabled: Bool = true

        var label: String {
            translator.translation(forKey: translationKey)
        }

        init(name: String, isOn: Bool, translationKey: String, translator: TranslationProvider) {
            self.translationKey = translationKey
            self.translator = translator
            self.name = name
            self.isOn = isOn
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
