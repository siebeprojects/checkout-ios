// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Payment
import Networking

struct NetworkRequestBuilder {
    func create(from operationRequest: OperationRequest) throws -> NetworkRequest.Operation {
        guard let onSelectURL = operationRequest.networkInformation.links["onselect"] else {
            throw PaymentError(errorDescription: "OperationRequest doesn't contain links.onselect which is mandatory")
        }

        let networkRequest = NetworkRequest.Operation(
            from: onSelectURL,
            account: operationRequest.form?.inputFields,
            autoRegistration: operationRequest.form?.autoRegistration,
            allowRecurrence: operationRequest.form?.allowRecurrence,
            providerRequest: nil,
            providerRequests: operationRequest.riskData
        )

        return networkRequest
    }
}
