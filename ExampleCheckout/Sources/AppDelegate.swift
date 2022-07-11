// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if isPayoneerCheckout(callbackURL: url) {
            NotificationCenter.default.post(name: .didReceivePaymentResultURL, object: url)
        }

        return true
    }

    private func isPayoneerCheckout(callbackURL url: URL) -> Bool {
        let payoneerCheckoutScheme = "com.payoneer.checkout.examplecheckout.mobileredirect"
        return url.scheme == payoneerCheckoutScheme
    }
}
