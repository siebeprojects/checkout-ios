import Foundation

final class PaymentSession {
    let network: NetworkGroup
    
    init(network: NetworkGroup) {
        self.network = network
    }
}
