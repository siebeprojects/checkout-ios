import Foundation

extension Input.Field {
    enum Validation {}
}

// MARK: - Model

extension Input.Field.Validation {
    enum Option {
        case preCheck
        case fullCheck
    }
    
    enum Result {
        case success
        case failure(ValidationError)
    }
    
    enum ValidationError: Error {
        case missingValue
        case invalidValue
        case incorrectLength
    }
    
    // MARK: Decodable models
    
    /// Network with validation rules for input fields
    struct Network: Decodable {
        /// Network code
        let code: String
        let items: [Rule]
    }
    
    /// Rule to check input field value
    struct Rule: Decodable {
        /// Input element's name
        let type: String
        
        /// Regular expression
        let regex: String?
        
        let maxLength: Int?
    }
}

extension Sequence where Element == Input.Field.Validation.Network {
    /// First found network with specified network code
    func first(withCode: String) -> Element? {
        for element in self where element.code == withCode {
            return element
        }
        
        return nil
    }
}

extension Sequence where Element == Input.Field.Validation.Rule {
    /// First found rule with specified type code
    func first(withType: String) -> Element? {
        for element in self where element.type == withType {
            return element
        }
        
        return nil
    }
}

// MARK: - Provider

extension Input.Field.Validation {
    class Provider {
        let networks: [Network]
        let defaultRules: [Input.Field.Validation.Rule]
        
        init() throws {
            // Network specific
            guard let networkValidationsJsonData = RawProvider.validationsJSON.data(using: .utf8) else {
                throw InternalError(description: "Couldn't make a JSON data from a validation JSON string")
            }
            
            networks = try JSONDecoder().decode([Network].self, from: networkValidationsJsonData)

            // Default
            guard let defaultValidationsData = RawProvider.validationsDefaultsJSON.data(using: .utf8) else {
                throw InternalError(description: "Couldn't make a JSON data from a default validation JSON string")
            }
            
            defaultRules = try JSONDecoder().decode([Rule].self, from: defaultValidationsData)
        }
        
        func getRule(forNetworkCode networkCode: String, withInputElementName inputName: String) -> Rule? {
            
            if let network = networks.first(withCode: networkCode) {
                return network.items.first(withType: inputName)
            } else if let defaultRule = defaultRules.first(withType: inputName) {
                return defaultRule
            } else {
                return nil
            }
        }
    }
}
