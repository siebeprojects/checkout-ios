import Foundation

struct PaymentSession {
    var networks: [PaymentNetwork]

    init(networks: [PaymentNetwork]) {
        self.networks = networks
    }
}
