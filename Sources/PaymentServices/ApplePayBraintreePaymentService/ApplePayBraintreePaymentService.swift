// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import BraintreeApplePay

final public class ApplePayBraintreePaymentService: NSObject, PaymentService {
    static let applePayNetworkCode = "APPLEPAY"
    static let applePayPaymentMethod = "WALLET"
    static let braintreeProviderCode = "BRAINTREE"

    let redirectController: RedirectController
    let connection: Connection

    public init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name) {
        self.connection = connection
        self.redirectController = RedirectController(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    public static func isSupported(networkCode: String, paymentMethod: String?, providers: [String]?) -> Bool {
        let isApplePay = networkCode == applePayNetworkCode && paymentMethod == applePayPaymentMethod && PKPaymentAuthorizationViewController.canMakePayments()
        let isBraintree = providers?.first == braintreeProviderCode
        return isApplePay && isBraintree
    }

    // MARK: - Process payment

    public func processPayment(operationRequest: OperationRequest, completion: @escaping PaymentService.CompletionBlock, presentationRequest: @escaping PaymentService.PresentationBlock) {
        // If network should be preset (first request of a PRESET flow), applicable network's operationType will be `PRESET`.
        if operationRequest.networkInformation.operationType == "PRESET" {
            preset(using: operationRequest, completion: completion)
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
                completion(.failure(error))
                return
            }

            // Configure Apple Pay controller
            let applePayController = ApplePayController(braintreeClient: braintreeClient, operationRequest: operationRequest, onSelectResult: onSelectResult, connection: connection)
            applePayController.completionHandler = {
                completion(applePayController.paymentResult)
            }

            do {
                // Present Apple Pay
                let viewController = try applePayController.createPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                presentationRequest(viewController)
            } catch {
                completion(.failure(error))
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

    public func delete(accountUsing accountURL: URL, completion: @escaping (Result<OperationResult, Error>) -> Void) {
        let deletionRequest = NetworkRequest.DeleteAccount(url: accountURL)

        let operation = SendRequestOperation(connection: connection, request: deletionRequest)
        operation.downloadCompletionBlock = completion
        operation.start()
    }
}
