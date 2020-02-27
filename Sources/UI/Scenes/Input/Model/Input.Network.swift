import Foundation

extension Input {
    class Network {
        let translation: TranslationProvider

        let label: String
        let logoData: Data?
        let inputFields: [InputField & CellRepresentable]
        let autoRegistration: Input.Field.Checkbox
        let allowRecurrence: Input.Field.Checkbox
        
        let switchRule: SmartSwitch.Rule?
        let networkCode: String

        init(networkCode: String, translator: TranslationProvider, label: String, logoData: Data?, inputFields: [InputField & CellRepresentable], autoRegistration: Input.Field.Checkbox, allowRecurrence: Input.Field.Checkbox, switchRule: SmartSwitch.Rule?) {
            self.networkCode = networkCode
            self.translation = translator
            
            self.label = label
            self.logoData = logoData
            self.inputFields = inputFields
            self.autoRegistration = autoRegistration
            self.allowRecurrence = allowRecurrence
            self.switchRule = switchRule
        }
    }
}

extension Input.Network: Equatable {
    static func == (lhs: Input.Network, rhs: Input.Network) -> Bool {
        return (lhs.networkCode == rhs.networkCode) && (lhs.label == rhs.label)
    }
}

#if canImport(UIKit)
import UIKit

extension Input.Network {
    var logo: UIImage? {
        guard let data = self.logoData else { return nil }
        return UIImage(data: data)
    }
}
#endif
