// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Networking
import Payment
import BraintreeApplePay

struct PaymentRequestSender {
    let applePayClient: BraintreeApplePayClientWrapper
    let operationRequest: OperationRequest
    let connection: Connection
    let onSelectResult: OperationResult

    func send(authorizedPayment payment: PKPayment, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        applePayClient.tokenizeApplePay(payment: payment) { tokenizationResult in
            switch tokenizationResult {
            case .success(let nonce):
                do {
                    guard let providerResponse = onSelectResult.providerResponse else {
                        throw PaymentError(errorDescription: "OperationResult from OnSelect operation doesn't contain providerResponse")
                    }

                    let chargeRequest = try NetworkRequestBuilder().createChargeRequest(from: operationRequest, providerCode: providerResponse.providerCode, nonce: nonce)
                    let chargeOperation = SendRequestOperation(connection: connection, request: chargeRequest)
                    chargeOperation.downloadCompletionBlock = completion
                    chargeOperation.start()
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
