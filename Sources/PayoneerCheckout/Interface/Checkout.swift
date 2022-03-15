// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import SafariServices

/// The entrypoint for interacting with the SDK. It has a 1:1 relationship with a payment session and is responsible for managing the checkout UI.
@objc public class Checkout: NSObject {
    private let configuration: CheckoutConfiguration
    private weak var presenter: UIViewController?
    private var paymentListViewController: UIViewController?
    private var paymentCompletionBlock: ((_ result: CheckoutResult) -> Void)?
    private lazy var chargePresetService = ChargePresetService(riskProviders: configuration.riskProviders)

    /// Initializes a `Checkout` with the given configuration.
    /// - Parameters:
    ///   - configuration: The configuration object to be used.
    @objc public init(configuration: CheckoutConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - Operations

@objc public extension Checkout {
    /// Presents the checkout UI.
    /// - Parameters:
    ///   - presenter: The view controller that will present the checkout UI.
    ///   - completion: The block to execute after the operation is complete and the UI is dismissed.
    ///
    ///     This completion block takes the following parameter:
    ///   - result: An object containing relevant information about the result of the operation.
    func presentPaymentList(from presenter: UIViewController, completion: @escaping (_ result: CheckoutResult) -> Void) {
        self.presenter?.dismiss(animated: false)
        self.presenter = presenter
        self.paymentCompletionBlock = completion
        self.paymentListViewController = PaymentListViewController(listResultURL: configuration.listURL, riskProviders: configuration.riskProviders, delegate: self)

        // Customize view controller

        let navigationController = UINavigationController(rootViewController: self.paymentListViewController!)

        presenter.present(navigationController, animated: true, completion: nil)
    }

    /// Charges a preset account.
    /// - Parameters:
    ///   - completion: The block to execute after the operation is complete. It includes an object with relevant information about the result of the operation.
    ///
    ///     This completion block takes the following parameter:
    ///   - result: An object containing relevant information about the result of the operation.
    func chargePresetAccount(completion: @escaping (_ result: CheckoutResult) -> Void) {
        chargePresetService.chargePresetAccount(
            usingListResultURL: configuration.listURL,
            completion: { [weak self] result in
                self?.dismiss {
                    completion(result)
                }
            },
            authenticationChallengeReceived: { [weak self] url in
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.delegate = self
                self?.presenter?.present(safariViewController, animated: true, completion: nil)
            }
        )
    }

    /// Dismisses the UI presented by the `Checkout` object.
    /// - Parameter completion: The block to execute after the UI is dismissed. You may specify nil for this parameter.
    func dismiss(_ completion: (() -> Void)? = nil) {
        if let presenter = presenter {
            presenter.dismiss(animated: true, completion: completion)
        } else {
            completion?()
        }
    }
}

// MARK: - PaymentDelegate

extension Checkout: PaymentDelegate {
    func paymentService(didReceiveResult result: CheckoutResult) {
        dismiss { [weak self] in
            self?.paymentCompletionBlock?(result)
            self?.paymentCompletionBlock = nil
        }
    }
}

// MARK: - SFSafariViewControllerDelegate

extension Checkout: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NotificationCenter.default.post(
            name: RedirectCallbackHandler.didFailReceivingPaymentResultURLNotification,
            object: nil,
            userInfo: [RedirectCallbackHandler.operationTypeUserInfoKey: "PRESET"]
        )
    }
}
