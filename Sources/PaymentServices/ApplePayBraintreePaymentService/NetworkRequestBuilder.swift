// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Payment
import Networking

struct NetworkRequestBuilder {
    func createOnSelectRequest(from operationRequest: OperationRequest) throws -> NetworkRequest.Operation {
        guard let onSelectURL = operationRequest.networkInformation.links["onSelect"] else {
            throw PaymentError(errorDescription: "OperationRequest doesn't contain links.onSelect which is mandatory")
        }

        return createNetworkRequest(from: operationRequest, url: onSelectURL)
    }

    /// Create a charge request.
    /// - Parameters:
    ///   - operationRequest: origin operation request from PayoneerCheckout
    ///   - providerCode: provider code from `onSelect` operation result
    ///   - nonce: braintree nonce
    func createChargeRequest(from operationRequest: OperationRequest, providerCode: String, nonce: String) throws -> NetworkRequest.Operation {
        guard let operationURL = operationRequest.networkInformation.links["operation"] else {
            throw PaymentError(errorDescription: "OperationRequest doesn't contain links.operation which is mandatory")
        }

        let nonceParameter = Parameter(name: "nonce", value: nonce)
        let nonceProviderParameters = ProviderParameters(providerCode: providerCode, providerType: nil, parameters: [nonceParameter])
        return createNetworkRequest(from: operationRequest, url: operationURL, providerRequest: nonceProviderParameters)
    }

    private func createNetworkRequest(from operationRequest: OperationRequest, url: URL, providerRequest: ProviderParameters? = nil) -> NetworkRequest.Operation {
        return NetworkRequest.Operation(
            from: url,
            account: operationRequest.form?.inputFields,
            autoRegistration: operationRequest.form?.autoRegistration,
            allowRecurrence: operationRequest.form?.allowRecurrence,
            providerRequest: providerRequest,
            providerRequests: operationRequest.riskData
        )
    }
}
