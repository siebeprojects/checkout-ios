import Foundation

@objc public class Payment: NSObject {
    let operationResult: OperationResult
    
    init(operationResult: OperationResult) {
        self.operationResult = operationResult
    }
}
