import Foundation

@objc public class PaymentResult: NSObject {
    public let operationResult: OperationResult?
    public let interaction: Interaction
    public let error: Error?

    init(operationResult: OperationResult?, interaction: Interaction, error: Error?) {
        self.operationResult = operationResult
        self.interaction = interaction
        self.error = error
    }
    
    convenience init(operationResult: Result<OperationResult, ErrorInfo>) {
        switch operationResult {
        case .success(let operationResult):
            self.init(operationResult: operationResult, interaction: operationResult.interaction, error: nil)
        case .failure(let errorInfo):
            self.init(operationResult: nil, interaction: errorInfo.interaction, error: errorInfo)
        }
    }
}
