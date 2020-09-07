import Foundation
import SafariServices

class BasicPaymentService: PaymentService {
    // MARK: - Constants
    private let supportedRedirectTypes = ["PROVIDER", "3DS2-HANDLER"]
    
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
            delegate?.paymentService(didReceivePaymentResult: result)
            return
        }

        connection.send(request: urlRequest) { result in
            switch result {
            case .failure(let error):
                let interaction = Interaction(code: .VERIFY, reason: .COMMUNICATION_FAILURE)
                let result = PaymentResult(operationResult: nil, interaction: interaction, error: error)
                self.delegate?.paymentService(didReceivePaymentResult: result)
                log(.debug, "Payment failed with error %@", error as CVarArg)
            case .success(let data):
                guard let data = data else {
                    let emptyResponseError = InternalError(description: "Empty response from a server on charge request")
                    let interaction = Interaction(code: .VERIFY, reason: .CLIENTSIDE_ERROR)
                    let result = PaymentResult(operationResult: nil, interaction: interaction, error: emptyResponseError)

                    self.delegate?.paymentService(didReceivePaymentResult: result)
                    log(.debug, "Payment failed with error %@", emptyResponseError as CVarArg)
                    return
                }

                do {
                    let operationResult = try JSONDecoder().decode(OperationResult.self, from: data)
 
                    if let redirect = operationResult.redirect, let redirectType = redirect.type, self.supportedRedirectTypes.contains(redirectType) {
                        self.redirectCallbackHandler.delegate = self.delegate
                        self.redirectCallbackHandler.subscribeForNotification()
                        try self.sendRedirect(using: redirect)
                        return
                    }
                    
                    let paymentResult = PaymentResult(operationResult: operationResult, interaction: operationResult.interaction, error: nil)
                    self.delegate?.paymentService(didReceivePaymentResult: paymentResult)
                    log(.debug, "Payment result received. Interaction: %@", operationResult.interaction.code, operationResult.interaction.reason)
                } catch {
                    let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
                    let result = PaymentResult(operationResult: nil, interaction: interaction, error: error)
                    self.delegate?.paymentService(didReceivePaymentResult: result)
                    log(.debug, "Payment failed with error %@", error as CVarArg)
                }
            }
        }
    }
    
    private func sendRedirect(using redirect: Redirect) throws {
        guard var components = URLComponents(url: redirect.url, resolvingAgainstBaseURL: false) else {
            throw InternalError(description: "Incorrect redirect url provided: %@", redirect.url.absoluteString)
        }
        
        guard case .GET = redirect.method else {
            throw InternalError(description: "Redirect method is not GET. Requested method was: %@", redirect.method.rawValue)
        }
        
        // Add or replace query items with parameters from `Redirect` object
        if let redirectParameters = redirect.parameters, !redirectParameters.isEmpty {
            var queryItems = components.queryItems ?? [URLQueryItem]()

            queryItems += redirectParameters.map {
                URLQueryItem(name: $0.name, value: $0.value)
            }
            
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw InternalError(description: "Unable to build URL from components")
        }
        
        log(.debug, "Redirecting user to an external url: %@", url.absoluteString)
        
        delegate?.paymentService(presentURL: url)
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

