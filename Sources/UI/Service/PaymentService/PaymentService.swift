import UIKit
import SafariServices

public protocol PaymentService: class {
    /// Returns whether the service can make payments
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool

    func send(paymentRequest: PaymentRequest)
    var delegate: PaymentServiceDelegate? { get set }

    init(using connection: Connection)
}

public protocol PaymentServiceDelegate: class {
    func paymentService(presentURL url: URL)
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult)
}

extension PaymentServiceDelegate {
    // Optional method
    public func paymentService(presentURL url: URL) {}
}
