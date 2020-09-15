import Foundation

/// Error returned from a server
@objc public class ErrorInfo: NSObject, Decodable {
    let resultInfo: String
    let interaction: Interaction
    
    /// - Note: Use `PaymentError` instead of that class when creating custom error info
    internal init(resultInfo: String, interaction: Interaction) {
        self.resultInfo = resultInfo
        self.interaction = interaction
    }
}

extension ErrorInfo: Error {
    var localizedDescription: String { return resultInfo }
}
