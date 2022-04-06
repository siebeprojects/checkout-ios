// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking

protocol OperationResultHandlerDelegate: AnyObject {
    func loadPaymentSession()
    func present(error: UIAlertController.AlertError)
    func dismiss(with result: Result<OperationResult, ErrorInfo>)
}

extension PaymentListViewController {
    class OperationResultHandler {
        weak var delegate: OperationResultHandlerDelegate?
    }
}

extension PaymentListViewController.OperationResultHandler: NetworkOperationResultHandler {
    func paymentListController(didReceiveOperationResult result: Result<OperationResult, ErrorInfo>, for request: OperationRequest?, network: Input.Network) {
        switch request {
        case let deletionRequest as DeletionRequest:
            handle(response: result, for: deletionRequest, network: network)
        case let paymentRequest as PaymentRequest:
            if paymentRequest.operationType == "UPDATE" {
                handle(response: result, forUpdateRequest: paymentRequest, network: network)
            } else {
                handle(response: result, for: paymentRequest, network: network)
            }
        default:
            let internalError = InternalError(description: "Unexpected request type, programmatic error")
            let errorInfo = CustomErrorInfo.createClientSideError(from: internalError)
            delegate?.dismiss(with: .failure(errorInfo))
        }
    }

    /// Show an alert view controller and reload after dismissal
    /// - Parameters:
    ///   - errorDescription: should be extracted from `resultInfo`
    fileprivate func reloadListWithError(errorDescription: String, interaction: Interaction, translation: TranslationProvider) {
        let errorInfo = ErrorInfo(resultInfo: errorDescription, interaction: interaction)
        var alertError = UIAlertController.AlertError(for: errorInfo, translator: translation)
        alertError.actions = [.init(label: .ok, style: .default) { [delegate] _ in
            delegate?.loadPaymentSession()
        }]
        delegate?.present(error: alertError)
    }
}

// MARK: Handler for `PaymentRequest`

private extension PaymentListViewController.OperationResultHandler {
    func handle(response: Result<OperationResult, ErrorInfo>, for request: PaymentRequest, network: Input.Network) {
        switch Interaction.Code(rawValue: response.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .charge)
            reloadListWithError(errorDescription: response.resultInfo, interaction: interaction, translation: network.translation)
        case .RELOAD:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: response)
        }
    }

    /// Handler for responses in `UPDATE` flow.
    ///
    /// Flow rules are defined in [PCX-1396](https://optile.atlassian.net/browse/PCX-1396).
    func handle(response: Result<OperationResult, ErrorInfo>, forUpdateRequest request: PaymentRequest, network: Input.Network) {
        switch Interaction.Code(rawValue: response.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .PROCEED:
            switch Interaction.Reason(rawValue: response.interaction.reason) {
            case .PENDING:
                // On `PROCEED/PENDING` display an alert and don't do anything in a list view
                let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .update)
                let errorInfo = CustomErrorInfo(resultInfo: response.resultInfo, interaction: interaction)
                var alertError = UIAlertController.AlertError(for: errorInfo, translator: network.translation)
                alertError.actions = [.init(label: .ok, style: .default, handler: nil)]
                delegate?.present(error: alertError)
            case .OK:
                delegate?.loadPaymentSession()
            default:
                delegate?.dismiss(with: response)
            }
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK, .RETRY:
            let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .update)
            reloadListWithError(errorDescription: response.resultInfo, interaction: interaction, translation: network.translation)
        case .RELOAD:
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: response)
        }
    }
}

// MARK: Handler for `DeletionRequest`

private extension PaymentListViewController.OperationResultHandler {
    func handle(response: Result<OperationResult, ErrorInfo>, for request: DeletionRequest, network: Input.Network) {
        switch Interaction.Code(rawValue: response.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let interaction = LocalizableInteraction.create(fromInteraction: response.interaction, flow: .delete)
            reloadListWithError(errorDescription: response.resultInfo, interaction: interaction, translation: network.translation)
        case .RELOAD, .PROCEED:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: response)
        }
    }
}
