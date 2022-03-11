// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout

class ViewController: UITableViewController {
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var themeSwitch: UISwitch!
    @IBOutlet private var showPaymentListButton: UIButton!
    @IBOutlet private var chargePresetAccountButton: ActivityIndicatableButton!

    private lazy var checkout: Checkout? = {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return nil
        }

        let configuration = CheckoutConfiguration(listURL: url)
        return Checkout(configuration: configuration)
    }()
}

// MARK: - Lifecycle

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        setTintColor(to: Theme.shared.tintColor)

        chargePresetAccountButton.setTitle(chargePresetAccountButton.title(for: .normal), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textField.becomeFirstResponder()
    }
}

// MARK: - Interaction

extension ViewController {
    @IBAction private func themeSwitchValueDidChange(_ sender: UISwitch) {
        Theme.shared = sender.isOn ? .custom : .standard
        setTintColor(to: Theme.shared.tintColor)
    }

    @IBAction private func showPaymentListDidTap(_ sender: UIButton) {
        checkout?.presentPaymentList(from: self) { result in
            self.presentAlert(with: result)
        }
    }

    @IBAction private func chargePresetAccountDidTap(_ sender: ActivityIndicatableButton) {
        startLoading()

        checkout?.chargePresetAccount { result in
            self.stopLoading()
            self.presentAlert(with: result)
        }
    }
}

// MARK: - State

extension ViewController {
    private func startLoading() {
        toggleControls(enabled: false)
        chargePresetAccountButton.isLoading = true
    }

    private func stopLoading() {
        toggleControls(enabled: true)
        chargePresetAccountButton.isLoading = false
    }

    private func toggleControls(enabled: Bool) {
        [showPaymentListButton, chargePresetAccountButton, textField, themeSwitch].forEach {
            $0?.isEnabled = enabled
        }

        let alphaValue = enabled ? 1 : 0.6

        [showPaymentListButton, chargePresetAccountButton].forEach {
            $0?.backgroundColor = $0?.backgroundColor?.withAlphaComponent(alphaValue)
        }
    }
}

// MARK: - Helpers

extension ViewController {
    /// Present `UIAlertController` with textual representation of `CheckoutResult`
    private func presentAlert(with result: CheckoutResult) {
        let alert = UIAlertController(title: "Payment Result", message: description(forResult: result), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

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

    private func description(forResult result: CheckoutResult) -> String {
        let paymentErrorText: String = {
            if let cause = result.cause {
                return cause.localizedDescription
            } else {
                return "n/a"
            }
        }()

        let messageDictionary: KeyValuePairs = [
            "ResultInfo": result.resultInfo,
            "Interaction code": result.interaction.code,
            "Interaction reason": result.interaction.reason,
            "Error": paymentErrorText
        ]

        return messageDictionary
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
}
