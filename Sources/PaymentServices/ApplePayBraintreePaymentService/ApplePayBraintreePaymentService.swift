// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment

@objc final public class ApplePayBraintreePaymentService: NSObject, PaymentService {
    let redirectController: RedirectController
    let connection: Connection

    public init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name) {
        self.connection = connection
        self.redirectController = RedirectController(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    public static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        return networkCode == "APPLEPAY" && paymentMethod == "WALLET"
    }

    // MARK: Process payment

    public func processPayment(operationRequest: Payment.OperationRequest, completion: @escaping (OperationResult?, Error?) -> Void, presentationRequest: @escaping (UIViewController) -> Void) {
        guard let onSelectRequest = operationRequest as? OnSelectRequest else {
            let error = PaymentError(errorDescription: "Programmatic error: input parameter should be of OnSelectRequest type")
            completion(nil, error)
            return
        }

        // Create Braintree API Client
        let braintreeFabric = BraintreeClientFabric(connection: connection, onSelectRequest: onSelectRequest)
        braintreeFabric.createBraintreeClient { braintreeCreationResult in
            switch braintreeCreationResult {
            case .success(let fabricResponse):
                guard let providerResponse = fabricResponse.onSelectResult.providerResponse else {
                    let error = PaymentError(errorDescription: "Response from a server doesn't contain providerResponse that is required to make onSelect call")
                    completion(nil, error)
                    return
                }

                // Create `PKPaymentRequest`
                let paymentRequestFabric = PaymentRequestFabric(providerResponse: providerResponse, braintreeClient: fabricResponse.braintreeClient)
                paymentRequestFabric.createPaymentRequest { paymentRequestCreationResult in
                    switch paymentRequestCreationResult {
                    case .success(let paymentRequest):
                        // FIXME: Not yet implemented
                        print(paymentRequest)
                        completion(nil, nil)
                    case .failure(let paymentRequestCreationError):
                        completion(nil, paymentRequestCreationError)
                    }
                }
            case .failure(let braintreeCreationError):
                completion(nil, braintreeCreationError)
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
