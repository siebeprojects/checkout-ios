import Foundation

class PaymentServicesFactory {
    var services: [PaymentService.Type] = .init()
    let connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    /// Register all known services
    func registerServices() {
        register(paymentService: BackendPaymentService.self)
    }

    private func register(paymentService: PaymentService.Type) {
        services.append(paymentService)
    }
    
    /// Lookup for appropriate payment service and create an instance if found
    func createPaymentService(forNetworkCode networkCode: String, paymentMethod: String?) -> PaymentService? {
        for service in services where service.canMakePayments(forNetworkCode: networkCode, paymentMethod: paymentMethod) {
            return service.init(using: connection)
        }
        
        return nil
    }
    
    func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        for service in services where service.canMakePayments(forNetworkCode: networkCode, paymentMethod: paymentMethod) {
            return true
        }
        
        return false
    }
}
