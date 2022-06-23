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

    // MARK: Process payment

    public func processPayment(operationRequest: OperationRequest, completion: @escaping PaymentService.CompletionBlock, presentationRequest: @escaping PaymentService.PresentationBlock) {
        // Make OnSelect call
        let onSelectRequest: NetworkRequest.Operation
        do {
            onSelectRequest = try NetworkRequestBuilder().createOnSelectRequest(from: operationRequest)
        } catch {
            completion(nil, error)
            return
        }

        // 1. Make OnSelect call
        let onSelectOperation = SendRequestOperation(connection: connection, request: onSelectRequest)
        onSelectOperation.downloadCompletionBlock = { onSelectRequestResult in
            // Unwrap OperationResult from onSelect call
            let onSelectResult: OperationResult

            switch onSelectRequestResult {
            case .success(let operationResult):
                onSelectResult = operationResult
            case .failure(let error):
                completion(nil, error)
                return
            }

            // Create Braintree client
            let braintreeClient: BTAPIClient

            do {
                braintreeClient = try BraintreeClientBuilder().createBraintreeClient(onSelectResult: onSelectResult)
            } catch {
                completion(nil, error)
                return
            }

            // 2. Create `PKPaymentRequest`
            self.createPaymentRequest(onSelectResult: onSelectResult, braintreeClient: braintreeClient) { paymentRequestCreationResult in
                let paymentRequest: PKPaymentRequest

                switch paymentRequestCreationResult {
                case .success(let createdPaymentRequest):
                    paymentRequest = createdPaymentRequest
                case .failure(let error):
                    completion(nil, error)
                    return
                }

                do {
                    // 3. Present ApplePay view controller, wait for authorization
                    try self.presentApplePayUI(paymentRequest: paymentRequest, presentationRequest: presentationRequest) { payment, applePayUIController in
                        // 4. Tokenize `PKPayment` and send charge request
                        let applePayClient = BraintreeApplePayClientWrapper(braintreeClient: braintreeClient)
                        let sender = PaymentRequestSender(applePayClient: applePayClient, operationRequest: operationRequest, connection: self.connection, onSelectResult: onSelectResult)
                        sender.send(authorizedPayment: payment) { paymentSendResult in
                            // 5. Return results
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
                } catch {
                    completion(nil, error)
                    return
                }
            }
        }
        onSelectOperation.start()
    }

    private func createPaymentRequest(onSelectResult: OperationResult, braintreeClient: BTAPIClient, completion: @escaping (Result<PKPaymentRequest, Error>) -> Void) {
        guard let providerResponse = onSelectResult.providerResponse else {
            let error = PaymentError(errorDescription: "Response from a server doesn't contain providerResponse which is required to create PKPaymentRequest")
            completion(.failure(error))
            return
        }

        let paymentRequestBuilder = PaymentRequestBuilder(providerResponse: providerResponse, braintreeClient: braintreeClient)
        paymentRequestBuilder.createPaymentRequest(completion: completion)
    }

    /// Present Apple Pay view controller.
    /// - Parameters:
    ///   - paymentRequest: payment request required by Apple Pay
    ///   - presentationRequest: forwarded to a merchant `presentationRequest` block
    ///   - didAuthorizePayment: tuple containing authorized `PKPaymentRequest` and Apple Pay UI controller, which could be used to set `PKPaymentAuthorizationResult` through `ApplePayUIController.applePayViewControllerHandler`
    private func presentApplePayUI(paymentRequest: PKPaymentRequest, presentationRequest: @escaping PaymentService.PresentationBlock, didAuthorizePayment: @escaping ((PKPayment, ApplePayUIController) -> Void)) throws {
        let applePayController = ApplePayUIController()
        let paymentViewController = try applePayController.createPaymentAuthorizationViewController(
            paymentRequest: paymentRequest,
            didAuthorizePayment: { didAuthorizePayment($0, applePayController) }
        )
        presentationRequest(paymentViewController)
    }

    // MARK: Delete

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
