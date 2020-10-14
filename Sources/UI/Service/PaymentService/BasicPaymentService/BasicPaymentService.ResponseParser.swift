import Foundation

extension BasicPaymentService {
    struct ResponseParser {
        private let supportedRedirectTypes = ["PROVIDER", "3DS2-HANDLER"]
        let operationType: String
    }
}

extension BasicPaymentService.ResponseParser {
    /// Parse server's http data response to enumeration
    func parse(paymentRequestResponse: Result<Data?, Error>) -> PaymentServiceParsedResponse {
        let data: Data

        switch paymentRequestResponse {
        case .failure(let error):
            // Return server's error info if it replied with error
            if let errorInfo = error as? ErrorInfo {
                return .result(.failure(errorInfo))
            }

            // Some network module's error
            let interactionCode = BasicPaymentService.getFailureInteractionCode(forOperationType: operationType)
            let interaction = Interaction(code: interactionCode, reason: .COMMUNICATION_FAILURE)
            let paymentError = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: interaction, underlyingError: error)
            return .result(.failure(paymentError))
        case .success(let responseData):
            guard let responseData = responseData else {
                let emptyResponseError = InternalError(description: "Empty response from a server on charge request")
                let interactionCode = BasicPaymentService.getFailureInteractionCode(forOperationType: operationType)
                let interaction = Interaction(code: interactionCode, reason: .CLIENTSIDE_ERROR)
                let paymentError = CustomErrorInfo(resultInfo: emptyResponseError.localizedDescription, interaction: interaction, underlyingError: emptyResponseError)
                return .result(.failure(paymentError))
            }

            data = responseData
        }

        do {
            let operationResult = try JSONDecoder().decode(OperationResult.self, from: data)

            if let redirect = operationResult.redirect, let redirectType = redirect.type, self.supportedRedirectTypes.contains(redirectType) {
                let url = try createURL(from: redirect)
                return .redirect(url)
            }

            return .result(.success(operationResult))
        } catch {
            let interactionCode = BasicPaymentService.getFailureInteractionCode(forOperationType: operationType)
            let interaction = Interaction(code: interactionCode, reason: .CLIENTSIDE_ERROR)
            let paymentError = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: interaction, underlyingError: error)
            return .result(.failure(paymentError))
        }
    }

    private func createURL(from redirect: Redirect) throws -> URL {
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

        return url
    }
}
