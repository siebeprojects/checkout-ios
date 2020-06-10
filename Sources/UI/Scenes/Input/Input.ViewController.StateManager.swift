import UIKit

extension Input.ViewController {
    class StateManager {
        unowned let vc: Input.ViewController
        
        var state: UIState = .inputFieldsPresentation {
            didSet {
                DispatchQueue.main.async {
                    self.changeState(to: self.state, from: oldValue)
                }
            }
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
    
    private func present(paymentResult: PaymentResult) {
        let message = "\(paymentResult.operationResult.resultInfo)\nInteraction code: \(paymentResult.operationResult.interaction.code)"
        let alert = UIAlertController(title: "Payment result", message: message, preferredStyle: .alert)
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
        case paymentResultPresentation(PaymentResult)
        case error(Error)
    }
}
