import UIKit

extension Input.ViewController {
    class StateManager {
        unowned let vc: Input.ViewController

        var state: UIState = .inputFieldsPresentation {
            didSet { self.changeState(to: self.state, from: oldValue) }
        }

        init(viewController: Input.ViewController) {
            self.vc = viewController
        }
    }
}

extension Input.ViewController.StateManager {
    fileprivate func changeState(to newState: UIState, from oldState: UIState) {
        switch oldState {
        case .paymentSubmission:
            setPaymentSubmission(isActive: false)
        default: break
        }

        switch newState {
        case .paymentSubmission:
            setPaymentSubmission(isActive: true)
        case .paymentResultPresentation(let paymentResult):
            present(paymentResult: paymentResult)
        case .error(let error, let unwindAction):
            present(error: error, onDismiss: unwindAction)
        default: break
        }
    }

    private func setPaymentSubmission(isActive: Bool) {
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = isActive
        }
        vc.navigationItem.leftBarButtonItem?.isEnabled = !isActive

        vc.tableController.dataSource.setEnabled(!isActive)
        vc.tableController.dataSource.setPaymentButtonState(isLoading: isActive)

        vc.collectionView.reloadData()
    }

    private func present(paymentResult: OperationResult?) {
        vc.navigationItem.setHidesBackButton(true, animated: true)

        let message: String

        if let paymentResult = paymentResult {
            message = "\(paymentResult.resultInfo)\nInteraction code: \(paymentResult.interaction.code)"
        } else {
            message = "Payment is okay, operation result is null"
        }

        let alert = UIAlertController(title: "Payment result", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { [vc] _ in
            vc.navigationController?.dismiss(animated: true, completion: nil)
            vc.delegate?.paymentController(paymentSucceedWith: paymentResult)
        })
        alert.addAction(okAction)

        vc.present(alert, animated: true, completion: nil)
    }

    private func present(error: Error, onDismiss: Input.ViewController.UnwindAction?) {
        let translator = vc.smartSwitch.selected.network.translation

        var title: String = translator.translation(forKey: "messages.error.default.title")
        var message: String? = translator.translation(forKey: "messages.error.default.text")

        if let localizableError = error as? Input.LocalizableError, let customTitle = translator.translation(forKey: localizableError.titleKey), let customMessage = translator.translation(forKey: localizableError.messageKey) {
            // If localizable error was thrown and we have all translations display that error
            title = customTitle
            message = customMessage
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: translator.translation(forKey: "button.ok.label"), style: .default, handler: { [vc] _ in
            guard let unwindAction = onDismiss else {
                // No unwind action was defined, don't dismiss view
                self.state = .inputFieldsPresentation
                return
            }
            
            vc.navigationController?.dismiss(animated: true, completion: nil)
            vc.delegate?.paymentController(paymentFailedWith: error, unwindAction: unwindAction)
        })
        alert.addAction(okAction)

        vc.present(alert, animated: true, completion: {
            self.state = .inputFieldsPresentation
        })
    }
}

extension Input.ViewController.StateManager {
    enum UIState {
        case inputFieldsPresentation
        case paymentSubmission
        case paymentResultPresentation(OperationResult?)
        case error(Error, onDismiss: Input.ViewController.UnwindAction?)
    }
}
