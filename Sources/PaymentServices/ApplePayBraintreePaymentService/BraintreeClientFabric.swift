// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Payment
import Networking
import BraintreeApplePay

struct BraintreeClientFabric {
    let connection: Connection
    let onSelectRequest: OnSelectRequest

    /// Create Braintree client using data from `onSelect` request being sent in this method.
    func createBraintreeClient(completion: @escaping (Result<BraintreeClientFabricResponse, Error>) -> Void) {
        onSelectRequest.send(using: connection) { result in
            switch result {
            case .success(let operationResult):
                do {
                    let braintreeClient = try self.createBraintreeClient(onSelectResult: operationResult)
                    let response = BraintreeClientFabricResponse(braintreeClient: braintreeClient, onSelectResult: operationResult)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let requestError):
                completion(.failure(requestError))
            }
        }
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

struct BraintreeClientFabricResponse {
    let braintreeClient: BTAPIClient
    let onSelectResult: OperationResult
}
