import Foundation

public class OperationResult: NSObject, Decodable {
    /// Descriptive information that complements the interaction advice
    let resultInfo: String

    /// Interaction advice for the operation result
    let interaction: Interaction

    /// If present, merchant is advised to redirect customer to corresponding redirect URL; this will lead to either
    /// PSP web-site to complete initiated payment, or it will be pointing to one of the merchants callback URLs from `LIST` session
    let redirect: Redirect?

    /// Provider response data given back by the target provider as a result of transaction action; this data should contain all needed information to continue customer's journey on the payment page in the scope of used network
    let providerResponse: ProviderParameters?
    
    internal init(resultInfo: String, interaction: Interaction, redirect: Redirect?, providerResponse: ProviderParameters? = nil) {
        self.resultInfo = resultInfo
        self.interaction = interaction
        self.redirect = redirect
        self.providerResponse = providerResponse
    }
}
