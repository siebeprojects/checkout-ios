// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

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
    func paymentController(didReceiveOperationResult result: Result<OperationResult, ErrorInfo>, for request: OperationRequest?, network: Input.Network) {
        switch request {
        case is DeletionRequest:
            handleDeletionRequestResult(result: result, network: network)
        case is PaymentRequest:
            handleChargeRequest(result: result, network: network)
        default:
            let error = InternalError(description: "Unknown request's type was forwarded, using CHARGE flow to process it")
            error.log()

            // This type of request is unknown, use the `CHARGE` flow
            handleChargeRequest(result: result, network: network)
        }
    }

    private func handleChargeRequest(result: Result<OperationResult, ErrorInfo>, network: Input.Network) {
        switch Interaction.Code(rawValue: result.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            reloadListWithError(errorDescription: result.resultInfo, interaction: result.interaction, translation: network.translation)
        case .RELOAD:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: result)
        }
    }

    private func handleDeletionRequestResult(result: Result<OperationResult, ErrorInfo>, network: Input.Network) {
        switch Interaction.Code(rawValue: result.interaction.code) {
        // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            reloadListWithError(errorDescription: result.resultInfo, interaction: result.interaction, translation: network.translation)
        case .RELOAD, .PROCEED:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            delegate?.loadPaymentSession()
        default:
            delegate?.dismiss(with: result)
        }
    }

    /// Show an alert view controller and reload after dismissal
    /// - Parameters:
    ///   - errorDescription: should be extracted from `resultInfo`
    private func reloadListWithError(errorDescription: String, interaction: Interaction, translation: TranslationProvider) {
        let errorInfo = ErrorInfo(resultInfo: errorDescription, interaction: interaction)
        var alertError = UIAlertController.AlertError(for: errorInfo, translator: translation)
        alertError.actions = [.init(label: .ok, style: .default) { [delegate] _ in
            delegate?.loadPaymentSession()
        }]

        delegate?.present(error: alertError)
    }
}
