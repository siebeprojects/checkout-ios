import Foundation

public protocol PaymentDelegate: class {
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult)
    func paymentViewControllerWillDismiss()
    func paymentViewControllerDidDismiss()
}

public extension PaymentDelegate {
    func paymentViewControllerWillDismiss() {}
    func paymentViewControllerDidDismiss() {}
}
