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
        case .error(let error, let isRetryable, let onDismissBlock):
            present(error: error, isRetryable: isRetryable, onDismissBlock: onDismissBlock)
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

    private func present(error: Error, isRetryable: Bool, onDismissBlock: @escaping () -> Void) {
        let translator = vc.smartSwitch.selected.network.translation

        let title, message: String

        if let localizableError = error as? Input.LocalizableError, let customTitle = translator.translation(forKey: localizableError.titleKey), let customMessage = translator.translation(forKey: localizableError.messageKey) {
            // If localizable error was thrown and we have all translations display that error
            title = customTitle
            message = customMessage
        } else {
            title = translator.translation(forKey: "messages.error.default.title")
            message = translator.translation(forKey: "messages.error.default.text")
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: translator.translation(forKey: "button.ok.label"), style: .default, handler: { _ in
            onDismissBlock()
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
        case error(Error, isRetryable: Bool, onDismissBlock: () -> Void)
    }
}
