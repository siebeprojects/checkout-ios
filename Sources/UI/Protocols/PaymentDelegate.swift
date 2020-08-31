import Foundation

public protocol PaymentDelegate: class {
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult)
}
