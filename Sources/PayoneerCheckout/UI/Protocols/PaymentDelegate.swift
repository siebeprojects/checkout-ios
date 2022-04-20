// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit

/// A protocol used to implement event handling for payment service events.
protocol PaymentDelegate: AnyObject {
    /// Method is called when payment result was received, you should handle a payment result and dismiss a view manually
    /// - Parameters:
    ///   - viewController: payment view controller, it should be dismissed
    func paymentService(didReceiveResult result: CheckoutResult)
}
