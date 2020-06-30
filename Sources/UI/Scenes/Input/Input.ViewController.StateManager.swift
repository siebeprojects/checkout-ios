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
        case .error(let error):
            present(error: error)
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
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        
        vc.present(alert, animated: true, completion: {
            self.state = .inputFieldsPresentation
        })
    }
    
    private func present(error: Error) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "Payment error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
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
        case error(Error)
    }
}
