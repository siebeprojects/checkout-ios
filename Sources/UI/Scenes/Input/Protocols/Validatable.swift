import Foundation

protocol Validatable: class {
    var validationRule: Input.Validation.Rule? { get }
    var validationErrorText: String? { get set }
    
    func validateAndSaveResult(options: Input.Validation.Options)
    func localize(error: Input.Validation.ValidationError) -> String
}

extension Validatable where Self: TextInputField {
    /// Validate and write result to `validationResult`
    func validateAndSaveResult(options: Input.Validation.Options) {
        switch validate(options: options) {
        case .success:
            validationErrorText = nil
        case .failure(let validationError):
            validationErrorText = localize(error: validationError)
        }
    }
    
    private func validate(options: Input.Validation.Options) -> Input.Validation.Result {
        // Value exists
        if options.contains(.valueExists) {
            guard let value = self.value, !value.isEmpty else {
                return .failure(.missingValue)
            }
        }
        
        guard let value = self.value, let rule = self.validationRule else {
            return .success
        }
        
        // Correct length
        if options.contains(.maxLength) {
            guard let maxLength = rule.maxLength else {
                return .success
            }
            
            guard value.count <= maxLength else {
                return .failure(.incorrectLength)
            }
        }
        
        // Valid value, we check validity only if value is not empty. If it is empty you want to check it with `.valueExists`
        if options.contains(.validValue), !value.isEmpty, let rule = self.validationRule {
            let isMatched = (value.range(of: rule.regex, options: .regularExpression) != nil)
            guard isMatched else {
                return .failure(.invalidValue)
            }
        }
        
        return .success
    }
}

