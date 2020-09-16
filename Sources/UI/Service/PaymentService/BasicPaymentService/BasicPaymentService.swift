import Foundation
import SafariServices

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
    private lazy var redirectCallbackHandler: RedirectCallbackHandler = .init()
    private let responseParser = ResponseParser()

    required init(using connection: Connection) {
        self.connection = connection
    }

    func send(paymentRequest: PaymentRequest) {
        let urlRequest: URLRequest
        do {
            urlRequest = try makeRequest(for: paymentRequest)
        } catch {
            let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
            let paymentError = CustomErrorInfo(resultInfo: "", interaction: interaction, underlyingError: error)
            delegate?.paymentService(didReceiveResponse: .result(.failure(paymentError)))
            return
        }

        connection.send(request: urlRequest) { result in
            let response = self.responseParser.parse(paymentRequestResponse: result)
            
            switch response {
            case .result(let result):
                log(.debug, "Payment result received. Interaction code: %@, reason: %@", result.interaction.code, result.interaction.reason)
            case .redirect(let url):
                log(.debug, "Redirecting user to an external url: %@", url.absoluteString)
                self.redirectCallbackHandler.delegate = self.delegate
                self.redirectCallbackHandler.subscribeForNotification()
            }
            
            self.delegate?.paymentService(didReceiveResponse: response)
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

