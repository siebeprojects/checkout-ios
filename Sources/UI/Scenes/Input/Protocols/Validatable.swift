import Foundation

protocol Validatable: class {
    var validationRule: Input.Validation.Rule? { get }
    var validationErrorText: String? { get set }
    
    func validateAndSaveResult()
    func localize(error: Input.Validation.ValidationError) -> String
}

extension Validatable where Self: TextInputField {
    /// Validate and write result to `validationResult`
    func validateAndSaveResult() {
        switch validate() {
        case .success:
            validationErrorText = nil
        case .failure(let validationError):
            validationErrorText = localize(error: validationError)
        }
    }
    
    private func validate() -> Input.Validation.Result {
        guard let value = self.value, !value.isEmpty else {
            return .failure(.missingValue)
        }
        
        guard let rule = self.validationRule else {
            return .success
        }
        
        let isMatched = (value.range(of: rule.regex, options: .regularExpression) != nil)
        guard isMatched else {
            return .failure(.invalidValue)
        }
        
        if let maxLength = rule.maxLength {
            guard value.count <= maxLength else {
                return .failure(.invalidValue)
            }
        }
        
        return .success
    }
}

