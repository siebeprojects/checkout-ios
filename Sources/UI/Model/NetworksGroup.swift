import Foundation

final class NetworkGroup {
    var title: String = String()
    var networks: [PaymentNetwork]
    
    init(networks: [PaymentNetwork]) {
        self.networks = networks
    }
}
