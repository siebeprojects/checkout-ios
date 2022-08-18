// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Payment
import Networking

/// Builder for `Networking` module requests.
struct NetworkRequestBuilder {
    enum LinkType: String {
        case operation, onSelect
    }

    func providerParameters(withProviderCode providerCode: String, withNonce nonce: String) -> ProviderParameters {
        let nonceParameter = Parameter(name: "nonce", value: nonce)
        return ProviderParameters(providerCode: providerCode, providerType: nil, parameters: [nonceParameter])
    }

    func networkRequest(from operationRequest: OperationRequest, linkType: LinkType, providerRequest: ProviderParameters? = nil) throws -> NetworkRequest.Operation {
        guard let url = operationRequest.networkInformation.links[linkType.rawValue] else {
            throw PaymentError(errorDescription: "OperationRequest links doesn't contain links." + linkType.rawValue + " which is mandatory")
        }

        return NetworkRequest.Operation(
            from: url,
            account: operationRequest.form?.inputFields,
            autoRegistration: operationRequest.form?.autoRegistration,
            allowRecurrence: operationRequest.form?.allowRecurrence,
            checkboxes: operationRequest.form?.checkboxes,
            providerRequest: providerRequest,
            providerRequests: operationRequest.riskData
        )
    }
}
