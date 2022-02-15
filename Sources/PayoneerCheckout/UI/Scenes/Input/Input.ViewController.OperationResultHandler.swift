// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

// MARK: - Delegate

protocol InputPaymentControllerDelegate: AnyObject {
    func inputPaymentController(presentURL url: URL)
    func inputPaymentController(route result: Result<OperationResult, ErrorInfo>, for request: OperationRequest)
    func inputPaymentController(inputShouldBeChanged error: ErrorInfo)

    /// Request is failed and error should be displayed
    /// - Parameters:
    ///   - request: could be `nil` if error was thrown before `OperationRequest` was created or sent
    func inputPaymentController(didFailWithError error: ErrorInfo, for request: OperationRequest?)
}

// MARK: - OperationResultHandler

extension Input.ViewController {
    class OperationResultHandler {
        weak var delegate: InputPaymentControllerDelegate?
    }
}

extension Input.ViewController.OperationResultHandler: PaymentServiceDelegate {
    func paymentService(didReceiveResponse response: PaymentServiceParsedResponse, for request: OperationRequest) {
        let serverResponse: Result<OperationResult, ErrorInfo>

        switch response {
        case .redirect(let url):
            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(presentURL: url)
            }
            return
        case .result(let result):
            serverResponse = result
        }

        // Handle internal `COMMUNICATION_FAILURE` error for all flows
        if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: serverResponse.interaction.reason), case let .failure(errorInfo) = serverResponse {
            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(didFailWithError: errorInfo, for: request)
            }
            return
        }

        // Handlers for each flow
        switch request {
        case let paymentRequest as PaymentRequest:
            if paymentRequest.operationType == "UPDATE" {
                handle(response: serverResponse, forUpdateRequest: paymentRequest)
            } else {
                handle(response: serverResponse, for: paymentRequest)
            }
        case let deletionRequest as DeletionRequest:
            handle(response: serverResponse, for: deletionRequest)
        default:
            let internalError = InternalError(description: "Unexpected request type, programmatic error")
            let errorInfo = CustomErrorInfo.createClientSideError(from: internalError)
            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(route: .failure(errorInfo), for: request)
            }
        }
    }
}

// MARK: Handler for `PaymentRequest`

extension Input.ViewController.OperationResultHandler {
    func handle(response: Result<OperationResult, ErrorInfo>, for request: PaymentRequest) {
        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: response.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .charge)
            let errorInfo = ErrorInfo(resultInfo: response.resultInfo, interaction: interaction)

            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(inputShouldBeChanged: errorInfo)
            }
        }

        // In other situations route to a parent view
        else {
            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(route: response, for: request)
            }
        }
    }

    /// Handler for responses in `UPDATE` flow.
    ///
    /// Flow rules are defined in [PCX-1396](https://optile.atlassian.net/browse/PCX-1396).
    func handle(response: Result<OperationResult, ErrorInfo>, forUpdateRequest request: PaymentRequest) {
        DispatchQueue.main.async {
            self.delegate?.inputPaymentController(route: response, for: request)
        }
    }
}

// MARK: Handler for `DeletionRequest`

extension Input.ViewController.OperationResultHandler {
    func handle(response: Result<OperationResult, ErrorInfo>, for request: DeletionRequest) {
        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: response.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .delete)
            let errorInfo = ErrorInfo(resultInfo: response.resultInfo, interaction: interaction)

            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(inputShouldBeChanged: errorInfo)
            }
        }

        // In other situations route to a parent view
        else {
            DispatchQueue.main.async {
                self.delegate?.inputPaymentController(route: response, for: request)
            }
        }
    }
}
