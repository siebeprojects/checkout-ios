import XCTest
@testable import Example

fileprivate func infoPlistValue(forKey key: String) -> String? {
    let value = Bundle(for: PaymentSessionService.self).infoDictionary?[key]
    return value as? String
}

class PaymentSessionService {
    let url: URL
    let merchantCode: String
    let merchantPaymentToken: String

    private let networkService = NetworkService()

    init?() {
        guard let merchantCode = infoPlistValue(forKey: "MERCHANT_CODE"),
              let merchantPaymentToken = infoPlistValue(forKey: "MERCHANT_PAYMENT_TOKEN") else {
            return nil
        }

        let stringURL = infoPlistValue(forKey: "PAYMENT_API_LISTURL")
        self.url = URL(string: stringURL!)!
        self.merchantCode = merchantCode
        self.merchantPaymentToken = merchantPaymentToken
    }

    func create(using transaction: Transaction, completion: @escaping ((URL?) -> Void)) {
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
                    XCTFail("Data is empty")
                    completion(nil)
                    return
                }

                do {
                    let paymentSession = try JSONDecoder().decode(PaymentSession.self, from: data)
                    completion(paymentSession.links.`self`)
                } catch {
                    XCTFail("\(error)")
                    completion(nil)
                }
            case .failure(let error):
                XCTFail("\(error)")
                completion(nil)
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
