// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct PaymentRequest {
    /// Payment network code.
    let networkCode: String
    let operationURL: URL
    var inputFields = [String: String]()
    var autoRegistration: Bool?
    var allowRecurrence: Bool?
    let operationType: String
}

extension PaymentRequest: OperationRequest {
    func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        let chargeRequestBody = Charge.Body(account: inputFields, autoRegistration: autoRegistration, allowRecurrence: allowRecurrence)
        let chargeRequest = Charge(from: operationURL, body: chargeRequestBody)
        let chargeOperation = SendRequestOperation(connection: connection, request: chargeRequest)
        chargeOperation.downloadCompletionBlock = completion
        chargeOperation.start()
    }
}
