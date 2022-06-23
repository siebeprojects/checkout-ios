// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import BraintreeApplePay

@objc final public class ApplePayBraintreePaymentService: NSObject, PaymentService {
    let redirectController: RedirectController
    let connection: Connection

    public init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name) {
        self.connection = connection
        self.redirectController = RedirectController(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    public static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        return networkCode == "APPLEPAY" && paymentMethod == "WALLET" && PKPaymentAuthorizationViewController.canMakePayments()
    }

    // MARK: - Process payment

    public func processPayment(operationRequest: OperationRequest, completion: @escaping PaymentService.CompletionBlock, presentationRequest: @escaping PaymentService.PresentationBlock) {
        let builder = PaymentRequestBuilder(connection: connection, operationRequest: operationRequest)

        // Create `PKPaymentRequest`
        builder.createPaymentRequest { paymentRequestCreationResult in
            let braintreeClient: BTAPIClient
            let paymentRequest: PKPaymentRequest
            let onSelectResult: OperationResult

            switch paymentRequestCreationResult {
            case .success(let output):
                braintreeClient = output.braintreeClient
                paymentRequest = output.paymentRequest
                onSelectResult = output.onSelectResult
            case .failure(let error):
                completion(nil, error)
                return
            }

            // Present ApplePay view controller, wait for authorization
            self.presentApplePayUI(paymentRequest: paymentRequest, presentationRequest: presentationRequest) { presentationResult in
                let payment: PKPayment
                let applePayUIController: ApplePayUIController

                switch presentationResult {
                case .success(let tuple):
                    payment = tuple.0
                    applePayUIController = tuple.1
                case .failure(let error):
                    completion(nil, error)
                    return
                }

                // Tokenize `PKPayment` and send a charge request
                let applePayClient = BraintreeApplePayClientWrapper(braintreeClient: braintreeClient)
                let sender = PaymentSender(applePayClient: applePayClient, operationRequest: operationRequest, connection: self.connection, onSelectResult: onSelectResult)

                sender.send(authorizedPayment: payment) { paymentSendResult in
                    switch paymentSendResult {
                    case .success(let operationResult):
                        let successResult = PKPaymentAuthorizationResult(status: .success, errors: nil)
                        applePayUIController.applePayViewControllerHandler?(successResult)
                        completion(operationResult, nil)
                    case .failure(let error):
                        let failureResult = PKPaymentAuthorizationResult(status: .failure, errors: [error])
                        applePayUIController.applePayViewControllerHandler?(failureResult)
                        completion(nil, error)
                    }
                }
            }
        }
    }

    /// Present Apple Pay view controller.
    /// - Parameters:
    ///   - paymentRequest: payment request required by Apple Pay
    ///   - presentationRequest: forwarded to a merchant `presentationRequest` block
    ///   - completion: tuple containing authorized `PKPaymentRequest` and Apple Pay UI controller, which could be used to set `PKPaymentAuthorizationResult` through `ApplePayUIController.applePayViewControllerHandler`
    private func presentApplePayUI(paymentRequest: PKPaymentRequest, presentationRequest: @escaping PaymentService.PresentationBlock, completion: @escaping ((Result<(PKPayment, ApplePayUIController), Error>) -> Void)) {
        let applePayController = ApplePayUIController()

        do {
            let paymentViewController = try applePayController.createPaymentAuthorizationViewController(
                paymentRequest: paymentRequest,
                didAuthorizePayment: { payment in
                    let authorizationResult = (payment, applePayController)
                    completion(.success(authorizationResult))
                }
            )

            presentationRequest(paymentViewController)
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Delete

    public func delete(accountUsing accountURL: URL, completion: @escaping (OperationResult?, Error?) -> Void) {
        let deletionRequest = NetworkRequest.DeleteAccount(url: accountURL)

        let operation = SendRequestOperation(connection: connection, request: deletionRequest)

        operation.downloadCompletionBlock = { result in
            switch result {
            case .success(let operationResult):
                completion(operationResult, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }

        operation.start()
    }
}
