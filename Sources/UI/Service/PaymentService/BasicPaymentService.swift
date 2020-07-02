import Foundation

class BasicPaymentService: PaymentService {
    // MARK: - Static methods
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        if let paymentMethod = paymentMethod {
            if isSupported(method: paymentMethod) { return true }
        }
        
        if isSupported(code: networkCode) { return true }
        
        return false
    }
    
    private static func isSupported(method: String) -> Bool {
        let supportedMethods: [PaymentMethod] = [.DEBIT_CARD, .CREDIT_CARD]
        guard let paymentMethod = PaymentMethod(rawValue: method) else {
            return false
        }
        
        return supportedMethods.contains(paymentMethod)
    }
    
    private static func isSupported(code: String) -> Bool {
        let supportedCodes = ["SEPADD", "PAYPAL"]
        return supportedCodes.contains(code)
    }
    
    // MARK: -
    
    weak var delegate: PaymentServiceDelegate?
    
    let connection: Connection
    
    required init(using connection: Connection) {
        self.connection = connection
    }
    
    func send(paymentRequest: PaymentRequest) {
        let urlRequest: URLRequest
        do {
            urlRequest = try makeRequest(for: paymentRequest)
        } catch {
            let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
            let result = PaymentResult(operationResult: nil, interaction: interaction, error: error)
            delegate?.paymentService(self, paymentResult: result)
            return
        }
        
        connection.send(request: urlRequest) { result in
            switch result {
            case .failure(let error):
                let interaction = Interaction(code: .VERIFY, reason: .COMMUNICATION_FAILURE)
                let result = PaymentResult(operationResult: nil, interaction: interaction, error: error)
                self.delegate?.paymentService(self, paymentResult: result)
            case .success(let data):
                guard let data = data else {
                    let emptyResponseError = InternalError(description: "Empty response from a server on charge request")
                    let interaction = Interaction(code: .VERIFY, reason: .CLIENTSIDE_ERROR)
                    let result = PaymentResult(operationResult: nil, interaction: interaction, error: emptyResponseError)
                    
                    self.delegate?.paymentService(self, paymentResult: result)
                    return
                }
                
                do {
                    let operationResult = try JSONDecoder().decode(OperationResult.self, from: data)
                    let paymentResult = PaymentResult(operationResult: operationResult, interaction: operationResult.interaction, error: nil)
                    self.delegate?.paymentService(self, paymentResult: paymentResult)
                } catch {
                    let interaction = Interaction(code: .VERIFY, reason: .CLIENTSIDE_ERROR)
                    let result = PaymentResult(operationResult: nil, interaction: interaction, error: error)
                    self.delegate?.paymentService(self, paymentResult: result)
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

private extension BasicPaymentService {
    struct ChargeRequest: Encodable {
        var account = [String: String]()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
        
        /// - Throws: `InternalError` if dictionary's value doesn't conform to `Encodable`
        init(inputFields: [String: String]) {
            for (name, value) in inputFields {
                switch name {
                case Input.Field.Checkbox.Constant.allowRegistration: autoRegistration = Bool(stringValue: value)
                case Input.Field.Checkbox.Constant.allowRecurrence: allowRecurrence = Bool(stringValue: value)
                default: account[name] = value
                }
            }
        }
    }
}
