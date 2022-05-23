// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking

protocol ListRequestResultHandlerDelegate: AnyObject {
    func loadPaymentSession()
    func present(error: UIAlertController.AlertError)
    func dismiss(with result: Result<OperationResult, ErrorInfo>)
}

extension PaymentListViewController {
    class RequestResultHandler {
        let localizer: TranslationProvider

        weak var delegate: ListRequestResultHandlerDelegate?

        init(localizer: TranslationProvider) {
            self.localizer = localizer
        }
    }
}

extension PaymentListViewController.RequestResultHandler {
    func requestHandler(didReceiveOperationResult result: Result<OperationResult, ErrorInfo>, forRequestType requestType: RequestSender.RequestType) {
        switch requestType {
        case .operation(let operationType):
            switch operationType {
            case "UPDATE": handle(updateResponse: result)
            default: handle(operationResponse: result, for: requestType)
            }
        case .deletion: handle(deletionResponse: result)
        }
    }

    /// Show an alert view controller and reload after dismissal
    /// - Parameters:
    ///   - errorDescription: should be extracted from `resultInfo`
    fileprivate func reloadListWithError(errorDescription: String, interaction: Interaction) {
        let errorInfo = ErrorInfo(resultInfo: errorDescription, interaction: interaction)
        var alertError = UIAlertController.AlertError(for: errorInfo, translator: localizer)
        alertError.actions = [.init(label: .ok, style: .default) { [delegate] _ in
            delegate?.loadPaymentSession()
        }]
        delegate?.present(error: alertError)
    }
}

// MARK: Handler for `PaymentRequest`

private extension PaymentListViewController.RequestResultHandler {
    private func handle(operationResponse: Result<OperationResult, ErrorInfo>, for requestType: RequestSender.RequestType) {
        switch Interaction.Code(rawValue: operationResponse.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let interaction = LocalizableInteraction.create(fromInteraction: operationResponse.interaction, flow: .charge)
            reloadListWithError(errorDescription: operationResponse.resultInfo, interaction: interaction)
        case .RELOAD:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: operationResponse)
        }
    }

    /// Handler for responses in `UPDATE` flow.
    ///
    /// Flow rules are defined in [PCX-1396](https://optile.atlassian.net/browse/PCX-1396).
    private func handle(updateResponse: Result<OperationResult, ErrorInfo>) {
        switch Interaction.Code(rawValue: updateResponse.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .PROCEED:
            switch Interaction.Reason(rawValue: updateResponse.interaction.reason) {
            case .PENDING:
                // On `PROCEED/PENDING` display an alert and don't do anything in a list view
                let interaction = LocalizableInteraction.create(fromInteraction: updateResponse.interaction, flow: .update)
                let errorInfo = CustomErrorInfo(resultInfo: updateResponse.resultInfo, interaction: interaction)
                var alertError = UIAlertController.AlertError(for: errorInfo, translator: localizer)
                alertError.actions = [.init(label: .ok, style: .default, handler: nil)]
                delegate?.present(error: alertError)
            case .OK:
                delegate?.loadPaymentSession()
            default:
                delegate?.dismiss(with: updateResponse)
            }
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK, .RETRY:
            let interaction = LocalizableInteraction.create(fromInteraction: updateResponse.interaction, flow: .update)
            reloadListWithError(errorDescription: updateResponse.resultInfo, interaction: interaction)
        case .RELOAD:
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: updateResponse)
        }
    }
}

// MARK: Handler for `DeletionRequest`

private extension PaymentListViewController.RequestResultHandler {
    private func handle(deletionResponse: Result<OperationResult, ErrorInfo>) {
        switch Interaction.Code(rawValue: deletionResponse.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let interaction = LocalizableInteraction.create(fromInteraction: deletionResponse.interaction, flow: .delete)
            reloadListWithError(errorDescription: deletionResponse.resultInfo, interaction: interaction)
        case .RELOAD, .PROCEED:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: deletionResponse)
        }
    }
}