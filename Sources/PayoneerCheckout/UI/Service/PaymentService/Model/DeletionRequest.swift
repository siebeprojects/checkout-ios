// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

class DeletionRequest {
    /// Payment network code.
    let accountURL: URL

    let operationType: String

    internal init(accountURL: URL, operationType: String) {
        self.accountURL = accountURL
        self.operationType = operationType
    }
}

extension DeletionRequest: OperationRequest {
    func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        let requestBody = NetworkRequest.DeleteAccount.Body(deleteRegistration: true, deleteRecurrence: true)
        let request = NetworkRequest.DeleteAccount(url: accountURL, body: requestBody)
        let operation = SendRequestOperation(connection: connection, request: request)
        operation.downloadCompletionBlock = completion
        operation.start()
    }
}
