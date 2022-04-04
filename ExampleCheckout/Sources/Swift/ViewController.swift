// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout
import IovationRiskProvider

class ViewController: UITableViewController {
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var customAppearanceSwitch: UISwitch!
    @IBOutlet private var showPaymentListButton: UIButton!
    @IBOutlet private var chargePresetAccountButton: ActivityIndicatableButton!

    private var checkout: Checkout?
}

// MARK: - Lifecycle

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        chargePresetAccountButton.setTitle(chargePresetAccountButton.title(for: .normal), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textField.becomeFirstResponder()
    }
}

// MARK: - Interaction

extension ViewController {
    @IBAction private func showPaymentListDidTap(_ sender: UIButton) {
        startNewCheckout()

        checkout?.presentPaymentList(from: self) { result in
            self.presentAlert(with: result)
        }
    }

    @IBAction private func chargePresetAccountDidTap(_ sender: ActivityIndicatableButton) {
        if checkout == nil {
            startNewCheckout()
        }

        startLoading()

        checkout?.chargePresetAccount(from: self) { result in
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
        [showPaymentListButton, chargePresetAccountButton, textField, customAppearanceSwitch].forEach {
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
    private func startNewCheckout() {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        let customAppearance = CheckoutAppearance(
            primaryTextColor: .black,
            secondaryTextColor: .darkGray,
            backgroundColor: .white,
            accentColor: .orange,
            errorColor: .red,
            borderColor: .lightGray,
            buttonTitleColor: .white,
            fontProvider: CustomFontProvider()
        )

        let appearance: CheckoutAppearance = customAppearanceSwitch.isOn ? customAppearance : .default

        let configuration = CheckoutConfiguration(
            listURL: url,
            appearance: appearance,
            riskProviders: [IovationRiskProvider.self]
        )

        checkout = Checkout(configuration: configuration)

        chargePresetAccountButton.isEnabled = true
    }

    /// Present `UIAlertController` with textual representation of `CheckoutResult`
    private func presentAlert(with result: CheckoutResult) {
        let alert = UIAlertController(title: "Payment Result", message: description(forResult: result), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
