// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import BraintreeApplePay

extension BraintreePaymentService {
    class PaymentRequestFabric {
        let operationResult: OperationResult
        fileprivate(set) var braintreeClient: BTAPIClient?

        internal init(operationResult: OperationResult) {
            self.operationResult = operationResult
        }
    }
}

extension BraintreePaymentService.PaymentRequestFabric {
    func createPaymentRequest(completion: @escaping ((Result<PKPaymentRequest, Error>) -> Void)) {
        do {
            let braintreeClient = try createBraintreeClient(parsing: operationResult)
            createPaymentRequest(braintreeClient: braintreeClient, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    private func createBraintreeClient(parsing operationResult: OperationResult) throws -> BTAPIClient {
        guard let tokenizationKey = operationResult.providerResponse?.parameters?["braintreeJsAuthorisation"] else {
            throw InternalError(description: "OperationResult doesn't contain braintreeJsAuthorisation")
        }

        guard let braintreeClient = BTAPIClient(authorization: tokenizationKey) else {
            throw InternalError(description: "Unable to initialize Braintree client, tokenization key could be incorrect")
        }

        self.braintreeClient = braintreeClient
        return braintreeClient
    }

    private func createPaymentRequest(braintreeClient: BTAPIClient, completion: @escaping (Result<PKPaymentRequest, Error>) -> Void) {
        let applePayClient = BTApplePayClient(apiClient: braintreeClient)
        // You can use the following helper method to create a PKPaymentRequest which will set the `countryCode`,
        // `currencyCode`, `merchantIdentifier`, and `supportedNetworks` properties.
        // You can also create the PKPaymentRequest manually. Be aware that you'll need to keep these in
        // sync with the gateway settings if you go this route.
        applePayClient.paymentRequest { (paymentRequest, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let paymentRequest = paymentRequest else {
                let error = InternalError(description: "Error in Braintree framework: undefined state, payment request and error are nil")
                completion(.failure(error))
                return
            }

            // Overwrite properties filled by Braintree if they're present in OperationResult

            if let appleMerchantId = self.operationResult.providerResponse?.parameters?["appleMerchantId"] {
                paymentRequest.merchantIdentifier = appleMerchantId
            }

            if let currencyCode = self.operationResult.providerResponse?.parameters?["currencyCode"] {
                paymentRequest.currencyCode = currencyCode
            }

            // Create summary items

            guard let summaryAmountString = self.operationResult.providerResponse?.parameters?["amountInMajorUnits"] else {
                let error = InternalError(description: "amountInMajorUnits is not present in onSelect operation result, couldn't create PKPaymentRequest")
                completion(.failure(error))
                return
            }

            let summaryAmountDecimal = NSDecimalNumber(string: summaryAmountString)

            paymentRequest.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Total", amount: summaryAmountDecimal)
            ]

            // TODO: Should we enable 3DS?
            paymentRequest.merchantCapabilities = .capability3DS

            completion(.success(paymentRequest))
        }
    }
}
