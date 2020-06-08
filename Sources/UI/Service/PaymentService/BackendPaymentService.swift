import Foundation

class BackendPaymentService: PaymentService {
    static func canMakePayments(forNetworkCode networkCode: String, paymentMethod: String?) -> Bool {
        let supportedCodes = ["AMEX", "CASTORAMA", "DINERS", "DISCOVER", "MASTERCARD", "UNIONPAY", "VISA", "VISA_DANKORT", "VISAELECTRON", "CARTEBANCAIRE", "MAESTRO", "MAESTROUK", "POSTEPAY", "SEPADD", "JCB"]
        return supportedCodes.contains(networkCode)
    }
    
    var delegate: PaymentServiceDelegate?
    
    let connection: Connection
    
    required init(using connection: Connection) {
        self.connection = connection
    }
    
    func send(paymentRequest: PaymentRequest) {
        let urlRequest: URLRequest
        do {
            urlRequest = try makeRequest(for: paymentRequest)
        } catch {
            delegate?.paymentService(self, didFailedWithError: error)
            return
        }
        
        connection.send(request: urlRequest) { result in
            switch result {
            case .failure(let error):
                self.delegate?.paymentService(self, didFailedWithError: error)
            case .success(let data):
                print(data)
                break
//                weakSelf.delegate?.paymentService(weakSelf, didAuthorizePayment: Payment())
            }
            
            return
        }
    }
    
    /// Make `URLRequest` from `PaymentRequest`
    private func makeRequest(for paymentRequest: PaymentRequest) throws -> URLRequest {
        var request = URLRequest(url: paymentRequest.operationURL)
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("application/vnd.optile.payment.enterprise-v1-extensible+json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.optile.payment.enterprise-v1-extensible+json", forHTTPHeaderField: "Accept")
        
        // Body
        let chargeRequest = try ChargeRequest(account: paymentRequest.inputFields)
        let jsonData = try JSONEncoder().encode(chargeRequest)
        request.httpBody = jsonData
        
        return request
    }
}

private extension BackendPaymentService {
    struct AnyEncodable: Encodable {
        let value: Encodable
        init(value: Encodable) {
            self.value = value
        }

        func encode(to encoder: Encoder) throws {
            try value.encode(to: encoder)
        }
    }
    
    struct ChargeRequest: Encodable {
        let account: [String: AnyEncodable]
        var autoRegistration: Bool?
        
        /// - Throws: `InternalError` if dictionary's value doesn't conform to `Encodable`
        init(account: [String: Any]) throws {
            self.account = try account.mapValues {
                guard let encodableValue = $0 as? Encodable else {
                    throw InternalError(description: "Unable to make JSON for charge request from dictionary: %@. Failed to encode a value: %@", objects: account, $0)
                }
                
                return AnyEncodable(value: encodableValue)
            }
        }
    }
}
