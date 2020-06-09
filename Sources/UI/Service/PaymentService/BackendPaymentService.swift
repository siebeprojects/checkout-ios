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
                guard let data = data else {
                    let emptyResponseError = InternalError(description: "Empty response from a server on charge request")
                    self.delegate?.paymentService(self, didFailedWithError: emptyResponseError)
                    return
                }
                
                do {
                    let operationResult = try JSONDecoder().decode(OperationResult.self, from: data)
                    let paymentResult = PaymentResult(operationResult: operationResult)
                    self.delegate?.paymentService(self, didAuthorizePayment: paymentResult)
                } catch {
                    self.delegate?.paymentService(self, didFailedWithError: error)
                }
            }
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
        let chargeRequest = ChargeRequest(inputFields: paymentRequest.inputFields)
        let jsonData = try JSONEncoder().encode(chargeRequest)
        request.httpBody = jsonData
        
        return request
    }
}

private extension BackendPaymentService {
    struct ChargeRequest: Encodable {
        var account: [String: String] = .init()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
        
        /// - Throws: `InternalError` if dictionary's value doesn't conform to `Encodable`
        init(inputFields: [String: String]) {
            for (name, value) in inputFields {
                switch name {
                case "autoRegistration": autoRegistration = Bool(stringValue: value)
                case "allowRecurrence": allowRecurrence = Bool(stringValue: value)
                default: account[name] = value
                }
            }
        }
    }
}
