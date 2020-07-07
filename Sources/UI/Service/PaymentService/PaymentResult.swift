import Foundation

@objc public class PaymentResult: NSObject {
    public let operationResult: OperationResult?
    public let interaction: Interaction
    public let error: Error?

    public init(operationResult: OperationResult?, interaction: Interaction, error: Error?) {
        self.operationResult = operationResult
        self.interaction = interaction
        self.error = error
    }
}
