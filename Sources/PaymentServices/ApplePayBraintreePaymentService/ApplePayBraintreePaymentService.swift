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

            // Configure Apple Pay controller
            let applePayController = ApplePayController(braintreeClient: braintreeClient, operationRequest: operationRequest, onSelectResult: onSelectResult, connection: self.connection)
            applePayController.completionHandler = {
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
