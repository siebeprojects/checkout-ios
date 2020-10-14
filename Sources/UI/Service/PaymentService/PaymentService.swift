import UIKit
import SafariServices

protocol PaymentService: class {
    /// Returns whether the service can make payments
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool

    func send(paymentRequest: PaymentRequest)
    var delegate: PaymentServiceDelegate? { get set }

    init(using connection: Connection)
}

protocol PaymentServiceDelegate: class {
    func paymentService(didReceiveResponse response: PaymentServiceParsedResponse)
}
