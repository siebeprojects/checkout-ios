// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Networking
import Payment
import BraintreeApplePay

struct PaymentRequestBuilder {
    /// Provider parameters from `OperationResult` for on select call
    let providerResponse: ProviderParameters
    let braintreeClient: BTAPIClient

    func createPaymentRequest(completion: @escaping (Result<PKPaymentRequest, Error>) -> Void) {
        let applePayClient = BTApplePayClient(apiClient: braintreeClient)
        applePayClient.paymentRequest { paymentRequest, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let paymentRequest = paymentRequest else {
                let error = PaymentError(errorDescription: "Error in Braintree framework: undefined state, payment request and error are nil")
                completion(.failure(error))
                return
            }

            do {
                try complement(paymentRequest: paymentRequest)
                completion(.success(paymentRequest))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Add missing data to `PKPaymentRequest`
    /// - Important: modifies `PKPaymentRequest`
    private func complement(paymentRequest: PKPaymentRequest) throws {
        // Overwrite properties filled by Braintree if they're present in OperationResult
        if let appleMerchantId = providerResponse.parameters?["appleMerchantId"] {
            paymentRequest.merchantIdentifier = appleMerchantId
        }

        if let currencyCode = providerResponse.parameters?["currencyCode"] {
            paymentRequest.currencyCode = currencyCode
        }

        // Create summary items
        guard let summaryAmountString = providerResponse.parameters?["amountInMajorUnits"] else {
            throw PaymentError(errorDescription: "amountInMajorUnits is not present in onSelect operation result, couldn't update PKPaymentRequest")
        }

        let summaryAmountDecimal = NSDecimalNumber(string: summaryAmountString)

        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Total", amount: summaryAmountDecimal)]
        paymentRequest.merchantCapabilities = .capability3DS
    }
}
