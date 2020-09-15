import Foundation

protocol ListViewControllerPaymentDelegate: class {
    func paymentController(didReceiveOperationResult result: Result<OperationResult, ErrorInfo>, for network: Input.Network)
}
