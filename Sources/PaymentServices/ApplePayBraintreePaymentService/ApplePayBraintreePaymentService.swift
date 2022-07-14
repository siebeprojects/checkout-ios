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
        // If network should be preset (first request of a PRESET flow), applicable network's operationType will be `PRESET`.
        if operationRequest.networkInformation.operationType == "PRESET" {
            preset(using: operationRequest) { presetResult in
                switch presetResult {
                case .success(let operationResult): completion(operationResult, nil)
                case .failure(let error): completion(nil, error)
                }
            }

            return
        }

        let builder = PaymentRequestBuilder(connection: connection, operationRequest: operationRequest)

        // Create `PKPaymentRequest`
        builder.createPaymentRequest { [connection] paymentRequestCreationResult in
            let braintreeClient: BTAPIClient
            let paymentRequest: PKPaymentRequest
            let onSelectResult: OperationResult

            switch paymentRequestCreationResult {
            case .success(let payload):
                braintreeClient = payload.braintreeClient
                paymentRequest = payload.paymentRequest
                onSelectResult = payload.onSelectResult
            case .failure(let error):
                completion(nil, error)
                return
            }

            // Configure Apple Pay controller
            let applePayController = ApplePayController(braintreeClient: braintreeClient, operationRequest: operationRequest, onSelectResult: onSelectResult, connection: connection)
            applePayController.completionHandler = {
                // Payment finished, route results
                switch applePayController.paymentResult {
                case .success(let operationResult): completion(operationResult, nil)
                case .failure(let error): completion(nil, error)
                }
            }

            do {
                // Present Apple Pay
                let viewController = try applePayController.createPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                presentationRequest(viewController)
            } catch {
                completion(nil, error)
            }
        }
    }

    // MARK: - Preset

    /// Preset account or applicable network using data from `OperationRequest`.
    public func preset(using operationRequest: OperationRequest, completion: @escaping (Result<OperationResult, Error>) -> Void) {
        let presetRequest: NetworkRequest.Operation

        do {
            let builder = NetworkRequestBuilder()
            presetRequest = try builder.networkRequest(from: operationRequest, linkType: .operation)
        } catch {
            completion(.failure(error))
            return
        }

        let operation = SendRequestOperation(connection: connection, request: presetRequest)
        operation.downloadCompletionBlock = completion
        operation.start()
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
