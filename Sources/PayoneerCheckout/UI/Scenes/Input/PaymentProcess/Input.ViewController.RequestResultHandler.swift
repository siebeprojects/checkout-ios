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
        let interaction: Interaction = {
            switch result {
            case .success(let operationResult):
                return operationResult.interaction
            case .failure(let error):
                return error.interaction
            }
        }()

        // Handle internal `COMMUNICATION_FAILURE` error for all flows
        if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: interaction.reason), case let .failure(errorInfo) = result {
            self.delegate?.requestHandler(communicationFailedWith: errorInfo, forRequestType: requestType)
            return
        }

        // Handlers for each flow
        switch requestType {
        case .operation(let operationType):
            switch operationType {
            case "UPDATE":
                handle(updateResult: result)
            default:
                handle(result: result, for: requestType)
            }
        case .deletion:
            handle(deletionResult: result)
        }
    }
}

// MARK: - Operation handlers

extension Input.ViewController.RequestResultHandler {
    private func handle(result: Result<OperationResult, ErrorInfo>, for requestType: RequestSender.RequestType) {
        let resultData: (interaction: Interaction, resultInfo: String) = {
            switch result {
            case .success(let operationResult):
                return (operationResult.interaction, operationResult.resultInfo)
            case .failure(let error):
                return (error.interaction, error.resultInfo)
            }
        }()

        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: resultData.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: resultData.interaction, flow: .charge)
            let errorInfo = ErrorInfo(resultInfo: resultData.resultInfo, interaction: interaction)

            self.delegate?.requestHandler(inputShouldBeChanged: errorInfo)
        }

        // In other situations route to a parent view
        else {
            self.delegate?.requestHandler(route: result, forRequestType: requestType)
        }
    }

    /// Handler for responses in `UPDATE` flow.
    ///
    /// Flow rules are defined in [PCX-1396](https://optile.atlassian.net/browse/PCX-1396).
    private func handle(updateResult: Result<OperationResult, ErrorInfo>) {
        self.delegate?.requestHandler(route: updateResult, forRequestType: .operation(type: "UPDATE"))
    }
}

// MARK: - Deletion handler

extension Input.ViewController.RequestResultHandler {
    private func handle(deletionResult: Result<OperationResult, ErrorInfo>) {
        let resultData: (interaction: Interaction, resultInfo: String) = {
            switch deletionResult {
            case .success(let operationResult):
                return (operationResult.interaction, operationResult.resultInfo)
            case .failure(let error):
                return (error.interaction, error.resultInfo)
            }
        }()

        // On retry show an error and leave on that view
        if case .RETRY = Interaction.Code(rawValue: resultData.interaction.code) {
            let interaction = LocalizableInteraction.create(fromInteraction: resultData.interaction, flow: .delete)
            let errorInfo = ErrorInfo(resultInfo: resultData.resultInfo, interaction: interaction)

            self.delegate?.requestHandler(inputShouldBeChanged: errorInfo)
        }

        // In other situations route to a parent view
        else {
            self.delegate?.requestHandler(route: deletionResult, forRequestType: .deletion)
        }
    }
}
