import Foundation

@objc public class PaymentRequest: NSObject {
    /// Payment network code.
    public let networkCode: String
        
    public let operationURL: URL
    
    /// Textual dictionary with input fields.
    public let inputFields: [String: String]
    
    internal init(networkCode: String, operationURL: URL, inputFields: [String: String]) {
        self.networkCode = networkCode
        self.operationURL = operationURL
        self.inputFields = inputFields
        
        super.init()
    }
}
