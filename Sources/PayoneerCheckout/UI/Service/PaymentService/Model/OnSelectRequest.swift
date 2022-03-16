// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct OnSelectRequest {
    let operationURL: URL
    let operationType: String

    // TODO: Temporarly solution, could be implemented in another way
    let paymentRequest: PaymentRequest
}

extension OnSelectRequest: OperationRequest {
    func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        let onSelectRequest = NetworkRequest.OnSelectRequest(url: operationURL)
        let operation = SendRequestOperation(connection: connection, request: onSelectRequest)
        operation.downloadCompletionBlock = completion
        operation.start()
    }
}
