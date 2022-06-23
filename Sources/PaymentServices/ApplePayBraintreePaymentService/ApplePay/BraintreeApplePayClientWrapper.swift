// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import BraintreeApplePay

/// Wrapper for `BTApplePayClient` packing possible undefined state to defined `Result` enumeration.
struct BraintreeApplePayClientWrapper {
    private let applePayClient: BTApplePayClient

    init(braintreeClient: BTAPIClient) {
        self.applePayClient = BTApplePayClient(apiClient: braintreeClient)
    }

    /// Tokenize `PKPayment` on Braintree.
    /// - Parameters:
    ///   - completion: result with nonce from Braintree which should be used for communication with other services.
    func tokenizeApplePay(payment: PKPayment, completion: @escaping ((Result<String, Error>) -> Void)) {
        applePayClient.tokenizeApplePay(payment) { nonce, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let nonce = nonce else {
                let nonceError = PaymentError(errorDescription: "Braintree SDK error: error and nonce are nil")
                completion(.failure(nonceError))
                return
            }

            completion(.success(nonce.nonce))
        }
    }
}
