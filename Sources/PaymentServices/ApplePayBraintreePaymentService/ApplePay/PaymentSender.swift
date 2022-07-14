// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Networking
import Payment
import BraintreeApplePay

/// A structure responsible for processing authorized `PKPayment`.
struct PaymentSender {
    let paymentTokenizer: PaymentTokenizer
    let operationRequest: OperationRequest
    let connection: Connection
    let onSelectResult: OperationResult

    /// Tokenize `PKPayment` and send it to a server.
    func send(authorizedPayment payment: PKPayment, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        paymentTokenizer.tokenizeApplePay(payment: payment) { tokenizationResult in
            let nonce: String

            switch tokenizationResult {
            case .success(let receivedNonce):
                nonce = receivedNonce
            case .failure(let error):
                completion(.failure(error))
                return
            }

            do {
                guard let providerResponse = onSelectResult.providerResponse else {
                    throw PaymentError(errorDescription: "OperationResult from OnSelect operation doesn't contain providerResponse")
                }

                let builder = NetworkRequestBuilder()
                let providerRequest = builder.providerParameters(withProviderCode: providerResponse.providerCode, withNonce: nonce)
                let operationRequest = try builder.networkRequest(from: operationRequest, linkType: .operation, providerRequest: providerRequest)
                let operation = SendRequestOperation(connection: connection, request: operationRequest)
                operation.downloadCompletionBlock = completion
                operation.start()
            } catch {
                completion(.failure(error))
            }
        }
    }
}
