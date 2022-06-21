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
            onSelectRequest = try NetworkRequestBuilder().create(from: operationRequest)
        } catch {
            completion(nil, error)
            return
        }

        let onSelectOperation = SendRequestOperation(connection: connection, request: onSelectRequest)
        onSelectOperation.downloadCompletionBlock = { onSelectRequestResult in
            // Unpack OperationResult
            let onSelectResult: OperationResult

            switch onSelectRequestResult {
            case .success(let operationResult):
                onSelectResult = operationResult
            case .failure(let error):
                completion(nil, error)
                return
            }

            // Process OperationResult
            self.handle(onSelectResult: onSelectResult, completion: { handleResult in
                switch handleResult {
                case .success(let operationResult): completion(operationResult, nil)
                case .failure(let error): completion(nil, error)
                }
            }, presentationRequest: presentationRequest)
        }
        onSelectOperation.start()
    }

    private func handle(onSelectResult: OperationResult, completion: @escaping ((Result<OperationResult, Error>) -> Void), presentationRequest: @escaping PaymentService.PresentationBlock) {
        let braintreeClient: BTAPIClient

        do {
            braintreeClient = try BraintreeClientBuilder().createBraintreeClient(onSelectResult: onSelectResult)
        } catch {
            completion(.failure(error))
            return
        }

        guard let providerResponse = onSelectResult.providerResponse else {
            let error = PaymentError(errorDescription: "Response from a server doesn't contain providerResponse which is required to create PKPaymentRequest")
            completion(.failure(error))
            return
        }

        // Create `PKPaymentRequest`
        let paymentRequestBuilder = PaymentRequestBuilder(providerResponse: providerResponse, braintreeClient: braintreeClient)
        paymentRequestBuilder.createPaymentRequest { paymentRequestCreationResult in
            switch paymentRequestCreationResult {
            case .success(let paymentRequest):
                do {
                    let paymentViewController = try ApplePayUIController().createPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                    presentationRequest(paymentViewController)
                } catch {
                    completion(.failure(error))
                }

//                let notImplementedError = PaymentError(errorDescription: "FIXME: Flow is not yet implemented")
//                completion(.failure(notImplementedError))
            case .failure(let paymentRequestCreationError):
                completion(.failure(paymentRequestCreationError))
            }
        }
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
