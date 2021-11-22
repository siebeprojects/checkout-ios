// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

private func infoPlistValue(forKey key: String) -> String? {
    let value = Bundle(for: PaymentSessionService.self).infoDictionary?[key]
    return value as? String
}

enum PaymentSessionServiceError: Error {
    case invalidURL
    case invalidMerchantCode
    case invalidPaymentToken
}

class PaymentSessionService {
    let url: URL
    let merchantCode: String
    let merchantPaymentToken: String

    private let networkService = NetworkService()

    init() throws {
        guard let urlString = infoPlistValue(forKey: "PAYMENT_API_LISTURL"), let url = URL(string: urlString) else { throw PaymentSessionServiceError.invalidURL }
        guard let merchantCode = infoPlistValue(forKey: "MERCHANT_CODE") else { throw PaymentSessionServiceError.invalidMerchantCode }
        guard let merchantPaymentToken = infoPlistValue(forKey: "MERCHANT_PAYMENT_TOKEN") else { throw PaymentSessionServiceError.invalidPaymentToken }

        self.url = url
        self.merchantCode = merchantCode
        self.merchantPaymentToken = merchantPaymentToken
    }

    func create(using transaction: Transaction, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        var httpRequest = URLRequest(url: url)

        // Body
        httpRequest.httpMethod = "POST"
        httpRequest.httpBody = try! JSONEncoder().encode(transaction)

        // Authorization
        let authField = createAuthorizationHeaderString(name: merchantCode, password: merchantPaymentToken)
        httpRequest.addValue(authField, forHTTPHeaderField: "Authorization")

        networkService.send(request: httpRequest) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure("Server's reply doesn't contain data"))
                    return
                }

                do {
                    let paymentSession = try JSONDecoder().decode(ListResult.self, from: data)
                    completion(.success(paymentSession))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Encode username and password for a basic authorization header.
    private func createAuthorizationHeaderString(name: String, password: String) -> String {
        let credentials = String(format: "%@:%@", name, password)
        let data = credentials.data(using: .utf8)!
        let base64encoded = data.base64EncodedString()
        return "Basic " + base64encoded
    }
}
