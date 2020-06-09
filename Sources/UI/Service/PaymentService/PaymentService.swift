import Foundation

public protocol PaymentService: class {
    /// Returns whether the service can make payments
    static func canMakePayments(forNetworkCode networkCode: String, paymentMethod: String?) -> Bool
    
    func send(paymentRequest: PaymentRequest)
    var delegate: PaymentServiceDelegate? { get set }
    
    init(using connection: Connection)
}

public protocol PaymentServiceDelegate {
    func paymentService(_ paymentService: PaymentService, didAuthorizePayment paymentResult: PaymentResult)
    func paymentService(_ paymentService: PaymentService, didFailedWithError error: Error)
}
