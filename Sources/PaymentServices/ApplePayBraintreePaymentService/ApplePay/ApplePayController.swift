// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import PassKit
import BraintreeApplePay

/// Controller responsible for creating Apple Pay view controller, handling it's delegates events and performing steps to finalize a payment.
///
/// ### Payment flow
/// 1. Listen for delegate event `didAuthorizePayment`.
/// 2. Tokenize `PKPayment` from payment authorization on Braintree and get nonce for this token.
/// 3. Send a token to a backend server using `links.operation` from `OperationRequest`. Save `OperationResult` to `paymentResult`
/// 4. Listen for delegate event `paymentAuthorizationViewControllerDidFinish`, send `paymentResult` to `completionHandler`.
class ApplePayController: NSObject {
    private let braintreeClient: BTAPIClient
    private let operationRequest: OperationRequest
    private let onSelectResult: OperationResult
    private let connection: Connection

    var completionHandler: (() -> Void)?

    private weak var paymentViewController: PKPaymentAuthorizationViewController?
    private(set) var paymentResult: Result<OperationResult, Error>

    init(braintreeClient: BTAPIClient, operationRequest: OperationRequest, onSelectResult: OperationResult, connection: Connection) {
        self.braintreeClient = braintreeClient
        self.operationRequest = operationRequest
        self.onSelectResult = onSelectResult
        self.connection = connection
        self.paymentResult = {
            // Initial error will be returned if payment cancelled before it was was started.
            let errorInfo = CustomErrorInfo(resultInfo: "Payment was aborted before starting", interaction: .init(code: .RELOAD, reason: .CLIENTSIDE_ERROR))
            return .failure(errorInfo)
        }()
    }

    /// When payment will be finished or dismissed, `completionHandler` block will be called. Use `paymentResult` to get payment's status.
    /// - Returns: configured Apple Pay view controller with assigned delegate, don't set custom delegate.
    func createPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest) throws -> PKPaymentAuthorizationViewController {
        guard let paymentViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            throw PaymentError(errorDescription: "Unable to create PKPaymentAuthorizationViewController because PKPaymentRequest may be invalid")
        }

        self.paymentViewController = paymentViewController
        paymentViewController.delegate = self
        return paymentViewController
    }
}

// MARK: PKPaymentAuthorizationViewControllerDelegate

extension ApplePayController: PKPaymentAuthorizationViewControllerDelegate {
    // This method could be called at any step, even when payment is in progress (e.g. Apple produces timeout error)
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            self.completionHandler?()
        }
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Tokenize `PKPayment` and send a charge request
        let applePayClient = BraintreeApplePayClientWrapper(braintreeClient: braintreeClient)
        let sender = PaymentSender(applePayClient: applePayClient, operationRequest: operationRequest, connection: self.connection, onSelectResult: onSelectResult)

        // Set an error if payment will be interrupted during network requests
        let interruptionError = CustomErrorInfo(resultInfo: "Payment was interrupted during a network request", interaction: .init(code: .VERIFY, reason: .CLIENTSIDE_ERROR))
        paymentResult = .failure(interruptionError)

        // Communicate with Braintree and backend server
        sender.send(authorizedPayment: payment) { paymentSendResult in
            self.paymentResult = paymentSendResult

            // Report result to Apple Pay view controller
            switch paymentSendResult {
            case .success:
                completion(.init(status: .success, errors: nil))
            case .failure(let error):
                completion(.init(status: .failure, errors: [error]))
            }
        }
    }
}
