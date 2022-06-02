// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout
import Networking
import Payment
import PassKit
import BraintreeApplePay
import os.log




@objc final public class ApplePayBraintreePaymentService: NSObject, PaymentService {
    let redirectController: RedirectController
    let connection: Connection

    public init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name) {
        self.connection = connection
        self.redirectController = RedirectController(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    public static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        true
    }

    public func processPayment(operationRequest: Payment.OperationRequest, completion: @escaping (OperationResult?, Error?) -> Void, presentationRequest: @escaping (UIViewController) -> Void) {
        guard let onSelectRequest = operationRequest as? OnSelectRequest else {
            let error = CustomErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: ""))
            completion(nil, error)
            return
        }

        onSelectRequest.send(using: connection) { result in
            switch result {
            case .success(let operationResult):
                print(operationResult)

                guard let tokenizationKey = operationResult.providerResponse?.parameters?.first(where: { $0.name == "braintreeJsAuthorisation" })?.value else {
                    print("OperationResult doesn't contain braintreeJsAuthorisation")
                    return
                }

                guard let braintreeClient = BTAPIClient(authorization: tokenizationKey) else {
                    print("Unable to initialize Braintree client, tokenization key could be incorrect")
                    return
                }

                print(tokenizationKey)

                print("SUCCESS")

            case .failure(let error):
                print(error)
            }
        }

//        BTAPIClient(authorization: <#T##String#>)
//
//        let applePayClient = BTApplePayClient(apiClient: braintreeClient)
//
//        applePayClient.paymentRequest { (paymentRequest, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let paymentRequest = paymentRequest else {
//                let error = InternalError(description: "Error in Braintree framework: undefined state, payment request and error are nil")
//                completion(.failure(error))
//                return
//            }
//
//            // Overwrite properties filled by Braintree if they're present in OperationResult
//            if let appleMerchantId = self.operationResult.providerResponse?.parameters?["appleMerchantId"] {
//                paymentRequest.merchantIdentifier = appleMerchantId
//            }
//
//            if let currencyCode = self.operationResult.providerResponse?.parameters?["currencyCode"] {
//                paymentRequest.currencyCode = currencyCode
//            }
//
//            // Create summary items
//            guard let summaryAmountString = self.operationResult.providerResponse?.parameters?["amountInMajorUnits"] else {
//                let error = InternalError(description: "amountInMajorUnits is not present in onSelect operation result, couldn't create PKPaymentRequest")
//                completion(.failure(error))
//                return
//            }
//
//            let summaryAmountDecimal = NSDecimalNumber(string: summaryAmountString)
//
//            paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: summaryAmountDecimal)]
//            paymentRequest.merchantCapabilities = .capability3DS
//
//            completion(.success(paymentRequest))
//        }
    }

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
