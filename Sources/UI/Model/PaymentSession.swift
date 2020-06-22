import Foundation

final class PaymentSession {
    let networks: [PaymentNetwork]
    let registeredAccounts: [RegisteredAccount]?
    
    /// Same as `ListResult.operationType`
    let operationType: String

    init(operationType: String, networks: [TranslatedModel<ApplicableNetwork>], accounts: [TranslatedModel<AccountRegistration>]?) {
        self.operationType = operationType
        let buttonLocalizationKey = "button.operation." + operationType.uppercased() + ".label"
        
        self.networks = networks.map {
            .init(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator)
        }
        
        self.registeredAccounts = accounts?.map {
            RegisteredAccount(from: $0.model, submitButtonLocalizationKey: buttonLocalizationKey, localizeUsing: $0.translator)
        }
    }
}
