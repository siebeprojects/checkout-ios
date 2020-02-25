import Foundation

extension Input {
    class Network {
        let translation: TranslationProvider

        let label: String
        let logoData: Data?
        let inputFields: [InputField & CellRepresentable]
        
        let switchRule: SmartSwitch.Rule?
        let networkCode: String
        
        init(networkCode: String, translator: TranslationProvider, label: String, logoData: Data?, inputFields: [InputField & CellRepresentable], switchRule: SmartSwitch.Rule?) {
            self.translation = translator
            self.networkCode = networkCode
            self.label = label
            self.logoData = logoData
            self.inputFields = inputFields
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

extension Collection where Element: Input.Network {
    func isInputFieldsGroupable() -> Bool {
        guard let firstNetwork = self.first else { return true }
        
        for network in self {
            guard firstNetwork.isInputFieldsGroupable(with: network) else { return false }
        }
        
        return true
    }
}

private extension Input.Network {
    func isInputFieldsGroupable(with otherNetwork: Input.Network) -> Bool {
        let lhs = inputFields
        let rhs = otherNetwork.inputFields
        
        guard lhs.count == rhs.count else { return false }
        
        for (index, lhsElement) in lhs.enumerated() {
            let rhsElement = rhs[index]
            
            guard
                lhsElement.name == rhsElement.name,
                lhsElement.inputElement.type == rhsElement.inputElement.type
            else { return false }
        }
        
        return true
    }
}
