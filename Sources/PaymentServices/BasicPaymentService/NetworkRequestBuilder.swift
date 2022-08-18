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
        guard let operationURL = operationRequest.networkInformation.links["operation"] else {
            throw NetworkRequestBuilderError.missingOperationLink
        }

        let networkRequest = NetworkRequest.Operation(
            from: operationURL,
            account: operationRequest.form?.inputFields,
            autoRegistration: operationRequest.form?.autoRegistration,
            allowRecurrence: operationRequest.form?.allowRecurrence,
            checkboxes: operationRequest.form?.checkboxes,
            providerRequest: nil,
            providerRequests: operationRequest.riskData
        )

        return networkRequest
    }
}

private enum NetworkRequestBuilderError: LocalizedError {
    case missingOperationLink

    var errorDescription: String? {
        switch self {
        case .missingOperationLink: return "OperationRequest doesn't contain links.operations which is mandatory"
        }
    }
}
