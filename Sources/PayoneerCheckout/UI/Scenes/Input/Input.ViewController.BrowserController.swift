// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import SafariServices
import Logging

// MARK: Initializers

extension Input.ViewController {
    class BrowserController: NSObject {
        weak var presenter: ModalPresenter?
        weak var safariViewController: SFSafariViewController?

        let smartSwitch: Input.SmartSwitch.Selector

        fileprivate var notificationSubscriptionToken: NSObjectProtocol?

        init(smartSwitch: Input.SmartSwitch.Selector) {
            self.smartSwitch = smartSwitch
        }

        func dismissBrowserViewController() {
            safariViewController?.dismiss(animated: true)
        }

        /// Present Safari View Controller with redirect URL
        func presentBrowser(with url: URL) {
            safariViewController?.dismiss(animated: true)

            // Preset SafariViewController
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.safariViewController = safariVC
            presenter?.present(safariVC, animated: true, completion: nil)
        }
    }
}

extension Input.ViewController.BrowserController {
    func subscribeForNotification() {
        notificationSubscriptionToken = NotificationCenter.default.addObserver(forName: Self.userDidClickLinkInPaymentView, object: nil, queue: nil, using: presentBrowser)
    }

    func unsubscribeFromNotification() {
        guard let token = self.notificationSubscriptionToken else { return }
        NotificationCenter.default.removeObserver(token)
    }

    private func presentBrowser(for notification: Notification) {
        guard let url = notification.userInfo?[Self.linkUserInfoKey] as? URL else {
            if #available(iOS 14.0, *) {
                logger.critical("Notification with incorrect userInfo was received, browser won't be opened")
            }
            return
        }

        presentBrowser(with: url)
    }
}

// MARK: - SFSafariViewControllerDelegate

extension Input.ViewController.BrowserController: SFSafariViewControllerDelegate {
    /// SafariViewController was closed by Done button
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        let operationType = smartSwitch.selected.network.operationType
        NotificationCenter.default.post(
            name: RedirectCallbackHandler.didFailReceivingPaymentResultURLNotification,
            object: nil,
            userInfo: [RedirectCallbackHandler.operationTypeUserInfoKey: operationType]
        )
    }
}

extension Input.ViewController.BrowserController {
    static let userDidClickLinkInPaymentView: NSNotification.Name = .init("BrowserControllerUserDidClickLinkInPaymentView")

    static var linkUserInfoKey: String { "link" }
}

extension Input.ViewController.BrowserController: Loggable {}
