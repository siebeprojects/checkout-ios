// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import UIKit

extension Input.ViewController {
    class RequestResultHandler {
        weak var delegate: InputRequestResultHandlerDelegate?
    }
}

extension Input.ViewController.RequestResultHandler: RequestSenderDelegate {
    func requestSender(presentationRequestReceivedFor viewControllerToPresent: UIViewController) {
        self.delegate?.requestHandler(present: viewControllerToPresent)
    }

    func requestSender(didReceiveResult result: Result<OperationResult, ErrorInfo>, for requestType: RequestSender.RequestType) {
        // Handle internal `COMMUNICATION_FAILURE` error for all flows
        if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: result.interaction.reason), case let .failure(errorInfo) = result {
            self.delegate?.requestHandler(communicationFailedWith: errorInfo, forRequestType: requestType)
            return
        }

        // Handlers for each flow
        switch requestType {
        case .operation(let operationType):
            switch operationType {
            case "UPDATE": handle(updateResponse: result)
            default: handle(operationResponse: result, for: requestType)
            }
        case .deletion: handle(deletionResponse: result)
        }
    }
}

// MARK: - Operation handlers

extension Input.ViewController.RequestResultHandler {
    private func handle(operationResponse: Result<OperationResult, ErrorInfo>, for requestType: RequestSender.RequestType) {
        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: operationResponse.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: operationResponse.interaction, flow: .charge)
            let errorInfo = ErrorInfo(resultInfo: operationResponse.resultInfo, interaction: interaction)

            self.delegate?.requestHandler(inputShouldBeChanged: errorInfo)
        }

        // In other situations route to a parent view
        else {
            self.delegate?.requestHandler(route: operationResponse, forRequestType: requestType)
        }
    }

    /// Handler for responses in `UPDATE` flow.
    ///
    /// Flow rules are defined in [PCX-1396](https://optile.atlassian.net/browse/PCX-1396).
    private func handle(updateResponse: Result<OperationResult, ErrorInfo>) {
        self.delegate?.requestHandler(route: updateResponse, forRequestType: .operation(type: "UPDATE"))
    }
}

// MARK: - Deletion handler

extension Input.ViewController.RequestResultHandler {
    private func handle(deletionResponse: Result<OperationResult, ErrorInfo>) {
        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: deletionResponse.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: deletionResponse.interaction, flow: .delete)
            let errorInfo = ErrorInfo(resultInfo: deletionResponse.resultInfo, interaction: interaction)

            self.delegate?.requestHandler(inputShouldBeChanged: errorInfo)
        }

        // In other situations route to a parent view
        else {
            self.delegate?.requestHandler(route: deletionResponse, forRequestType: .deletion)
        }
    }
}
