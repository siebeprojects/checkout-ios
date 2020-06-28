import Foundation

@objc public class PaymentResult: NSObject {
    public let operationResult: OperationResult
    public var interaction: Interaction { operationResult.interaction }
    
    public init(operationResult: OperationResult) {
        self.operationResult = operationResult
    }
}
