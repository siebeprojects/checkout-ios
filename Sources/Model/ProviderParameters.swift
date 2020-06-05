import Foundation

public class ProviderParameters: NSObject, Decodable {
    /// The code of payment provider
    let providerCode: String
    
    /// An array of parameters
    let parameters: [Parameter]
}
