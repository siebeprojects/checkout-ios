import Foundation

@objc public class PaymentRequest: NSObject {
    /// Payment network code.
    public let networkCode: String
    
    /// Operation type for this `LIST` session.
    ///
    /// Possible values: `CHARGE`, `PRESET`, `PAYOUT`, `UPDATE`
    public let operationType: String?
    
    public let operationURL: URL
    
    /// Textual dictionary with input fields.
    public let inputFields: [String: String]
    
    internal init(networkCode: String, operationType: String?, operationURL: URL, inputFields: [String: String]) {
        self.networkCode = networkCode
        self.operationType = operationType
        self.operationURL = operationURL
        self.inputFields = inputFields
        
        super.init()
    }
}
