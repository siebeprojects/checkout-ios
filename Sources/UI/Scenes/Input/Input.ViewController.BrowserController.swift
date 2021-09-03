// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import SafariServices

// MARK: Initializers

extension Input.ViewController {
    class BrowserController: NSObject {
        weak var presenter: ModalPresenter?
        weak var safariViewController: SFSafariViewController?

        let smartSwitch: Input.SmartSwitch.Selector

        init(smartSwitch: Input.SmartSwitch.Selector) {
            self.smartSwitch = smartSwitch
        }
        
        func dismissBrowserViewController() {
            safariViewController?.dismiss(animated: true, completion: nil)
        }

        /// Present Safari View Controller with redirect URL
        func paymentController(presentURL url: URL) {
            safariViewController?.dismiss(animated: true, completion: nil)

            // Preset SafariViewController
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.safariViewController = safariVC
            presenter?.present(safariVC, animated: true, completion: nil)
        }
    }
}

// MARK: - SFSafariViewControllerDelegate

extension Input.ViewController.BrowserController: SFSafariViewControllerDelegate {
    /// SafariViewController was closed by Done button
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Get operation type from the last path component
        let operationType = smartSwitch.selected.network.operationURL.lastPathComponent
        NotificationCenter.default.post(
            name: RedirectCallbackHandler.didFailReceivingPaymentResultURLNotification,
            object: nil,
            userInfo: [RedirectCallbackHandler.operationTypeUserInfoKey: operationType]
        )
    }
}
