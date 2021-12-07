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
    @IBOutlet weak var showPaymentListButton: UIButton!
    @IBOutlet weak var chargePresetAccountButton: ActivityIndicatableButton!

    fileprivate var isEnabled: Bool = true {
        didSet {
            [showPaymentListButton, chargePresetAccountButton, textField, themeSwitch].forEach { $0?.isEnabled = isEnabled }

            if isEnabled {
                [showPaymentListButton, chargePresetAccountButton].forEach { $0?.backgroundColor = $0?.backgroundColor?.withAlphaComponent(1) }
            } else {
                [showPaymentListButton, chargePresetAccountButton].forEach { $0?.backgroundColor = $0?.backgroundColor?.withAlphaComponent(0.6) }
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
        chargePresetAccountButton.setTitle(chargePresetAccountButton.title(for: .normal), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textField.becomeFirstResponder()
    }

    // MARK: Outlets

    @IBAction func themeSwitchValueDidChange(_ sender: UISwitch) {
        Theme.shared = sender.isOn ? .custom : .standard
        setTintColor(to: Theme.shared.tintColor)
    }

    @IBAction func showPaymentListDidTap(_ sender: UIButton) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        let viewController = PaymentListViewController(listResultURL: url)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func chargePresetAccountDidTap(_ sender: ActivityIndicatableButton) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        // Change UI state to loading
        isEnabled = false
        sender.isLoading = true

        // Charge a preset account
        let service = ChargePresetService()
        chargePresetService = service
        service.delegate = self
        service.chargePresetAccount(usingListResultURL: url)
    }

    // MARK: -

    /// Present `UIAlertController` with textual representation of `PaymentResult`
    func presentAlert(with paymentResult: PaymentResult) {
        let alert = UIAlertController(title: "Payment result", message: paymentResult.debugDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - PaymentDelegate

extension ViewController: PaymentDelegate {
    func paymentService(didReceivePaymentResult paymentResult: PaymentResult, viewController: PaymentListViewController) {
        navigationController?.popViewController(animated: true, completion: {
            self.presentAlert(with: paymentResult)
        })
    }
}

// MARK: - Preset flow

extension ViewController: ChargePresetDelegate {
    func chargePresetService(didReceivePaymentResult paymentResult: PaymentResult, viewController: UIViewController?) {
        // Revert UI state back to normal
        isEnabled = true
        chargePresetAccountButton.isLoading = false

        // Preset payment result
        if let viewController = viewController {
            viewController.dismiss(animated: true, completion: {
                self.presentAlert(with: paymentResult)
            })
        } else {
            self.presentAlert(with: paymentResult)
        }
    }

    func chargePresetService(didRequestPresenting viewController: UIViewController) {
        // Preset service requested to show a view controller (in the most cases it is used to show a challenge browser view)
        self.present(viewController, animated: true, completion: nil)
    }
}

extension ViewController {
    private func setTintColor(to color: UIColor) {
        view.tintColor = color
        themeSwitch.onTintColor = color
        textField.tintColor = color
        showPaymentListButton.backgroundColor = color
        chargePresetAccountButton.backgroundColor = color
        setNavigationBarColor(to: color)
    }

    private func setNavigationBarColor(to color: UIColor) {
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
