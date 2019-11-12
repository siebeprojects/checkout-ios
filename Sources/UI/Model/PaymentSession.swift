import Foundation

final class PaymentSession {
    let networks: [PaymentNetwork]
    
    init(networks: [PaymentNetwork]) {
        self.networks = networks
    }
}
