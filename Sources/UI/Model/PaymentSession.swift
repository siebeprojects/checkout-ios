import Foundation

final class PaymentSession {
    let networks: [PaymentNetwork]
    let registeredAccounts: [RegisteredAccount]?
    
    init(networks: [PaymentNetwork], registeredAccounts: [RegisteredAccount]?) {
        self.networks = networks
        self.registeredAccounts = registeredAccounts
    }
}
