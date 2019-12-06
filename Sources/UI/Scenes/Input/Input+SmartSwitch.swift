import Foundation

extension Input {
    enum SmartSwitch {}
}

// MARK: - Rule

extension Input.SmartSwitch {
    /// Rule to detect network type based on regular expreession
    struct Rule: Decodable {
        /// Network code
        let code: String
        
        /// Regular expression
        let regex: String
    }
    
    fileprivate struct Root: Decodable {
        let items: [Rule]
    }
}

extension Sequence where Element == Input.SmartSwitch.Rule {
    func first(withCode: String) -> Element? {
        for element in self where element.code == withCode {
            return element
        }
        
        return nil
    }
}

// MARK: - Provider

extension Input.SmartSwitch {
    /// Provides SmartSwitch rules
    class Provider {
        func getRules() throws -> [Rule] {
            let jsonString = RawProvider.groupsJSON
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw InternalError(description: "Unable to encode string to data")
            }
            
            let root = try JSONDecoder().decode(Root.self, from: jsonData)
            return root.items
        }
    }
}

// MARK: - Selector

extension Input.SmartSwitch {
    struct Selector {
        let networks: [Input.Network]
        let currentNetwork: Input.Network
                
        /// Find an appropriate network for the specified account number. Input values will be moved to a new network's input fields.
        func select(usingAccountNumber accountNumber: String) -> Input.Network? {
            for network in networks {
                guard let rule = network.switchRule else { continue }
                
                let isMatched = (accountNumber.range(of: rule.regex, options: .regularExpression) != nil)
                guard isMatched else { continue }
                                
                return network
            }
            
            return nil
        }
        
        func moveInputValues(to newNetwork: Input.Network) {
            for (index, oldField) in currentNetwork.inputFields.enumerated() {
                newNetwork.inputFields[index].value = oldField.value
                oldField.value = nil
            }
        }
    }
}

private extension NSRegularExpression {
    func matches(string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return self.firstMatch(in: string, options: [], range: range) != nil
    }
}
