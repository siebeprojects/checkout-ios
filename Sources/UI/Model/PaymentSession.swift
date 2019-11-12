import Foundation

final class PaymentSession {
    let listResult: ListResult
    
    let networks: [PaymentNetwork]
    
    init(listResult: ListResult, networks: [PaymentNetwork]) {
        self.listResult = listResult
        self.networks = networks
    }
}
