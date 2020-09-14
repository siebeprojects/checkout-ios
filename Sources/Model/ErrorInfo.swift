import Foundation

/// Error returned from a server
@objc public class ErrorInfo: NSObject, Decodable {
    let resultInfo: String
    let interaction: Interaction

    struct Interaction: Decodable {
        let code, reason: String
    }
    
    internal init(resultInfo: String, interaction: ErrorInfo.Interaction) {
        self.resultInfo = resultInfo
        self.interaction = interaction
    }
}

extension ErrorInfo: Error {
    var localizedDescription: String { return resultInfo }
}
