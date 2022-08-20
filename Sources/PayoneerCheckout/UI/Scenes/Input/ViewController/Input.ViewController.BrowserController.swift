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
        weak var presenter: ViewControllerPresenter?
        weak var safariViewController: SFSafariViewController?

        private var notificationSubscriptionToken: NSObjectProtocol?

        func dismissBrowserViewController() {
            safariViewController?.dismiss(animated: true)
        }

        /// Present Safari View Controller with redirect URL
        func presentBrowser(with url: URL) {
            safariViewController?.dismiss(animated: true)

            // Preset SafariViewController
            let safariVC = SFSafariViewController(url: url)
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

extension Input.ViewController.BrowserController {
    static let userDidClickLinkInPaymentView: NSNotification.Name = .init("BrowserControllerUserDidClickLinkInPaymentView")

    static var linkUserInfoKey: String { "link" }
}

extension Input.ViewController.BrowserController: Loggable {}
