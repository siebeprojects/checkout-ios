import Foundation

extension Input {
    enum Validation {}
}

// MARK: - Model

extension Input.Validation {
    enum Result {
        case success
        case failure(ValidationError)
    }
    
    enum ValidationError: Error {
        case missingValue
        case invalidValue
    }
    
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
        let regex: String
        
        let maxLength: Int?
    }
}

extension Sequence where Element == Input.Validation.Network {
    /// First found network with specified network code
    func first(withCode: String) -> Element? {
        for element in self where element.code == withCode {
            return element
        }
        
        return nil
    }
}

extension Sequence where Element == Input.Validation.Rule {
    /// First found rule with specified type code
    func first(withType: String) -> Element? {
        for element in self where element.type == withType {
            return element
        }
        
        return nil
    }
}

// MARK: - Provider

extension Input.Validation {
    class Provider {
        func get() throws -> [Network] {
            guard let jsonData = RawProvider.validationsJSON.data(using: .utf8) else {
                throw InternalError(description: "Couldn't make a JSON data from a validation JSON string")
            }
            
            let networks = try JSONDecoder().decode([Network].self, from: jsonData)
            return networks
        }
    }
}
