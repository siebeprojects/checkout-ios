// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Payment
import Networking
import BraintreeApplePay

struct BraintreeClientFabric {
    func createBraintreeClient(onSelectResult: OperationResult) throws -> BTAPIClient {
        guard let tokenizationKey = onSelectResult.providerResponse?.parameters?.first(where: { $0.name == "braintreeJsAuthorisation" })?.value else {
            throw PaymentError(errorDescription: "OperationResult doesn't contain braintreeJsAuthorisation")
        }

        guard let braintreeClient = BTAPIClient(authorization: tokenizationKey) else {
            throw PaymentError(errorDescription: "Unable to initialize Braintree client, tokenization key could be incorrect")
        }

        return braintreeClient
    }
}
