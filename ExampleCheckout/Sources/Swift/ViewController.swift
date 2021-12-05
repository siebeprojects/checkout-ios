// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout

class ViewController: UITableViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chargePresetAccount: ActivityIndicatableButton!

    fileprivate var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                [sendButton, chargePresetAccount, textField, themeSwitch].forEach { $0?.isEnabled = isEnabled }
                [sendButton, chargePresetAccount].forEach { $0?.backgroundColor = $0?.backgroundColor?.withAlphaComponent(1) }
            } else {
                [sendButton, chargePresetAccount, textField, themeSwitch].forEach { $0?.isEnabled = isEnabled }
                [sendButton, chargePresetAccount].forEach { $0?.backgroundColor = $0?.backgroundColor?.withAlphaComponent(0.6) }
            }
        }
    }

    private var chargePresetService: ChargePresetService?

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        setTintColor(to: Theme.shared.tintColor)

        // Set title programmaticaly for `ActivityIndicatableButton` from Storyboard's value
        chargePresetAccount.setTitle(chargePresetAccount.title(for: .normal), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textField.becomeFirstResponder()
    }

    // MARK: Outlets

    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        Theme.shared = sender.isOn ? .custom : .standard
        setTintColor(to: Theme.shared.tintColor)
    }

    @IBAction func sendRequest(_ sender: Any) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        let viewController = PaymentListViewController(listResultURL: url)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func chargePresetAccount(_ sender: Any) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        isEnabled = false
        chargePresetAccount.isLoading = true

        let service = ChargePresetService()
        chargePresetService = service
        service.delegate = self
        service.chargePresetAccount(usingListResultURL: url)
    }
}

// MARK: - PaymentDelegate

extension ViewController: PaymentDelegate {
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult, viewController: PaymentListViewController) {
        navigationController?.popViewController(animated: true, completion: {
            self.presentAlert(with: paymentResult)
        })
    }

    private func presentAlert(with paymentResult: PaymentResult) {
        let paymentErrorText: String

        if let error = paymentResult.cause {
            paymentErrorText = "\(error)"
        } else {
            paymentErrorText = "n/a"
        }

        let messageDictionary = [
            TextLine(key: "ResultInfo", description: paymentResult.resultInfo),
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

// MARK: - Preset flow

extension ViewController: ChargePresetDelegate {
    func chargePresetService(didReceivePaymentResult paymentResult: PaymentResult, viewController: UIViewController?) {
        isEnabled = true
        chargePresetAccount.isLoading = false

        if let viewController = viewController {
            viewController.dismiss(animated: true, completion: {
                self.presentAlert(with: paymentResult)
            })
        } else {
            self.presentAlert(with: paymentResult)
        }
    }

    func chargePresetService(didRequestPresenting viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
}

private extension ViewController {
    func setTintColor(to color: UIColor) {
        themeSwitch.onTintColor = color
        textField.tintColor = color
        sendButton.backgroundColor = color
        chargePresetAccount.backgroundColor = color

        if #available(iOS 13.0, *) {
            // Change large title's background color
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = color
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController?.navigationBar.setNeedsLayout()
            navigationController?.navigationBar.layoutIfNeeded()
        } else {
            navigationController?.navigationBar.barTintColor = color
        }
    }
}

private struct TextLine {
    let key, description: String
}
