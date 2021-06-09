// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol InputPaymentControllerDelegate: class {
    func paymentController(presentURL url: URL)
    func paymentController(route result: Result<OperationResult, ErrorInfo>, for request: OperationRequest)
    func paymentController(inputShouldBeChanged error: ErrorInfo)

    /// Request is failed and error should be displayed
    /// - Parameters:
    ///   - request: could be `nil` if error was thrown before `OperationRequest` was created or sent
    func paymentController(didFailWith error: ErrorInfo, for request: OperationRequest?)
}

extension Input.ViewController {
    class PaymentController {
        let paymentServiceFactory: PaymentServicesFactory

        weak var delegate: InputPaymentControllerDelegate?

        init(paymentServiceFactory: PaymentServicesFactory) {
            self.paymentServiceFactory = paymentServiceFactory
        }
    }
}

extension Input.ViewController.PaymentController {
    func delete(network: Input.Network) {
        let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        service?.delegate = self

        guard let selfLink = network.apiModel.links?["self"] else {
            let error = InternalError(description: "API model doesn't contain links.self property")
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }

        let request = DeletionRequest(accountURL: selfLink, operationType: network.apiModel.operationType)
        service?.send(operationRequest: request)
    }
    
    func submitPayment(for network: Input.Network) {
        let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        service?.delegate = self

        let inputFieldsDictionary: [String: String]
        do {
            inputFieldsDictionary = try createInputFields(from: network)
        } catch {
            let errorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR), underlyingError: error)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }

        let request = PaymentRequest(networkCode: network.networkCode, operationURL: network.operationURL, inputFields: inputFieldsDictionary)

        service?.send(operationRequest: request)
    }
    
    private func createInputFields(from network: Input.Network) throws -> [String: String] {
        var inputFieldsDictionary = [String: String]()
        for element in network.uiModel.inputFields + network.uiModel.separatedCheckboxes {
            if element.name == "expiryDate" {
                // Transform expiryDate to month and a full year
                let dateComponents = try createDateComponents(fromExpiryDateString: element.value)
                inputFieldsDictionary["expiryMonth"] = dateComponents.month
                inputFieldsDictionary["expiryYear"] = dateComponents.year
            } else {
                inputFieldsDictionary[element.name] = element.value
            }
        }

        return inputFieldsDictionary
    }

    /// Create month and full year for short date string
    /// - Parameter expiryDate: example `03/30`
    /// - Returns: month and full year
    private func createDateComponents(fromExpiryDateString expiryDate: String) throws -> (month: String, year: String) {
        let expiryMonth = String(expiryDate.prefix(2))
        let shortYear = String(expiryDate.suffix(2))
        let expiryYear = try DateFormatter.string(fromShortYear: shortYear)
        return (month: expiryMonth, year: expiryYear)
    }
}

extension Input.ViewController.PaymentController: PaymentServiceDelegate {
    func paymentService(didReceiveResponse response: PaymentServiceParsedResponse, for request: OperationRequest) {
        let serverResponse: Result<OperationResult, ErrorInfo>

        switch response {
        case .redirect(let url):
            DispatchQueue.main.async {
                self.delegate?.paymentController(presentURL: url)
            }
            return
        case .result(let result):
            serverResponse = result
        }

        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: serverResponse.interaction.code) {
            let errorInfo = ErrorInfo(resultInfo: serverResponse.resultInfo, interaction: serverResponse.interaction)

            DispatchQueue.main.async {
                self.delegate?.paymentController(inputShouldBeChanged: errorInfo)
            }
        }

        // If a reason is a communication failure, propose to retry
        else if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: serverResponse.interaction.reason),
                case let .failure(errorInfo) = serverResponse {
            DispatchQueue.main.async {
                self.delegate?.paymentController(didFailWith: errorInfo, for: request)
            }
        }

        // In other situations route to a parent view
        else {
            DispatchQueue.main.async {
                self.delegate?.paymentController(route: serverResponse, for: request)
            }
        }
    }
}

private extension Input.Network.APIModel {
    var links: [String: URL]? {
        switch self {
        case .account(let account): return account.links
        case .network(let network): return network.links
        }
    }

    var operationType: String {
        switch self {
        case .account(let account): return account.operationType
        case .network(let network): return network.operationType
        }
    }
}
