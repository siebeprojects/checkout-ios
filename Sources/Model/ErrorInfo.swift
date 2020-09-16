import Foundation

/// Error returned from a server
@objc public class ErrorInfo: NSObject, Decodable {
    public let resultInfo: String
    public let interaction: Interaction
    
    /// - Note: Use `CustomErrorInfo` instead of that class when creating custom error info
    internal init(resultInfo: String, interaction: Interaction) {
        self.resultInfo = resultInfo
        self.interaction = interaction
    }
}

extension ErrorInfo: Error {
    var localizedDescription: String { return resultInfo }
}
