// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Networking
import Payment
import BraintreeApplePay

struct PaymentRequestBuilderOutput {
    /// Model for Apple Pay UI
    let paymentRequest: PKPaymentRequest

    let braintreeClient: BTAPIClient

    /// `OperationResult` after on select call
    let onSelectResult: OperationResult
}

struct PaymentRequestBuilder {
    let connection: Connection
    let operationRequest: OperationRequest

    func createPaymentRequest(completion: @escaping (Result<PaymentRequestBuilderOutput, Error>) -> Void) {
        // Make OnSelect call
        let onSelectRequest: NetworkRequest.Operation
        do {
            onSelectRequest = try NetworkRequestBuilder().createOnSelectRequest(from: operationRequest)
        } catch {
            completion(.failure(error))
            return
        }

        let onSelectOperation = SendRequestOperation(connection: connection, request: onSelectRequest)
        onSelectOperation.downloadCompletionBlock = { onSelectRequestResult in
            // Unwrap OperationResult from onSelect call
            let onSelectResult: OperationResult

            switch onSelectRequestResult {
            case .success(let operationResult):
                onSelectResult = operationResult
            case .failure(let error):
                completion(.failure(error))
                return
            }

            // Create Braintree client
            let braintreeClient: BTAPIClient

            do {
                braintreeClient = try createBraintreeClient(onSelectResult: onSelectResult)
            } catch {
                completion(.failure(error))
                return
            }

            guard let providerResponse = onSelectResult.providerResponse else {
                let error = PaymentError(errorDescription: "Response from a server doesn't contain providerResponse which is required to create PKPaymentRequest")
                completion(.failure(error))
                return
            }

            // Get `PKPaymentRequest` from Braintree
            self.fetchPaymentRequestFromBraintree(braintreeClient: braintreeClient, providerResponse: providerResponse) { fetchResult in
                switch fetchResult {
                case .success(let paymentRequest):
                    let output = PaymentRequestBuilderOutput(paymentRequest: paymentRequest, braintreeClient: braintreeClient, onSelectResult: onSelectResult)
                    completion(.success(output))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        onSelectOperation.start()
    }

    /// Send request to Braintree to create `PKPaymentRequest`.
    /// - Parameters:
    ///   - providerResponse: provider parameters from `OperationResult` for on select call
    private func fetchPaymentRequestFromBraintree(braintreeClient: BTAPIClient, providerResponse: ProviderParameters, completion: @escaping (Result<PKPaymentRequest, Error>) -> Void) {
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
                try complement(paymentRequest: paymentRequest, providerResponse: providerResponse)
                completion(.success(paymentRequest))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Add missing data to `PKPaymentRequest`
    /// - Important: modifies `PKPaymentRequest`
    private func complement(paymentRequest: PKPaymentRequest, providerResponse: ProviderParameters) throws {
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

    private func createBraintreeClient(onSelectResult: OperationResult) throws -> BTAPIClient {
        guard let tokenizationKey = onSelectResult.providerResponse?.parameters?.first(where: { $0.name == "braintreeJsAuthorisation" })?.value else {
            throw PaymentError(errorDescription: "OperationResult doesn't contain braintreeJsAuthorisation")
        }

        guard let braintreeClient = BTAPIClient(authorization: tokenizationKey) else {
            throw PaymentError(errorDescription: "Unable to initialize Braintree client, tokenization key could be incorrect")
        }

        return braintreeClient
    }
}
