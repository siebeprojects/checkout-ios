import Foundation

final class PaymentSession {
    let networks: [PaymentNetwork]
    let registeredAccounts: [RegisteredAccount]?
    let operationType: String?
    
    init(listResult: ListResult, networks: [PaymentNetwork], registeredAccounts: [RegisteredAccount]?) {
        self.networks = networks
        self.registeredAccounts = registeredAccounts
        self.operationType = listResult.operationType
        
        for network in networks {
            network.session = self
        }
        
        if let accounts = registeredAccounts {
            for account in accounts {
                account.session = self
            }
        }
    }
}
