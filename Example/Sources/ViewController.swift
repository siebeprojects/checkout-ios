import UIKit
import Optile

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    var paymentResult: PaymentResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .navigationBarTintColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let pasteText = UIPasteboard.general.string, let _ = URL(string: pasteText) {
            // Paste URL from clipboard automatically
            textField.text = pasteText
        } else {
            textField.becomeFirstResponder()
        }
    }

    @IBAction func sendRequest(_ sender: Any) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        let viewController = List.ViewController(listResultURL: url)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)    }
}

extension ViewController: PaymentDelegate {
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult) {
        self.paymentResult = paymentResult
    }

    func paymentViewControllerDidDismiss() {
        guard let result = paymentResult else { return }
        // Payment result was received
        self.presentAlert(with: result)
        
        paymentResult = nil
    }
    
    private func presentAlert(with paymentResult: PaymentResult) {
        let paymentErrorText: String
            
        if let error = paymentResult.error {
            paymentErrorText = "\(error)"
        } else {
            paymentErrorText = "n/a"
        }
        
        let messageDictionary = [
            TextLine(key: "ResultInfo", description: paymentResult.operationResult?.resultInfo ?? "n/a"),
            TextLine(key: "Interaction code", description: paymentResult.interaction.code),
            TextLine(key: "Interaction reason", description: paymentResult.interaction.reason),
            TextLine(key: "Error", description: paymentErrorText)
        ]

        let message = messageDictionary.map { "\($0.key): \($0.description)" }.joined(separator: "\n")
        let alert = UIAlertController(title: "Payment result", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

private struct TextLine {
    let key, description: String
}

private extension UIColor {
    static var navigationBarTintColor: UIColor {
        return UIColor(red: 0.0, green: 137.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
    }
}

private extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping () -> ()) {
        popViewController(animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
