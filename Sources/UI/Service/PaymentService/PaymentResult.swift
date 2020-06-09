import Foundation

@objc public class PaymentResult: NSObject {
    public let operationResult: OperationResult
    
    public init(operationResult: OperationResult) {
        self.operationResult = operationResult
    }
}
