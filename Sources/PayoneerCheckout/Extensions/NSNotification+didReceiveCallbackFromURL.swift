// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public extension NSNotification.Name {
    static let didReceivePaymentResultURL = NSNotification.Name(rawValue: "BasicPaymentServiceDidReceivePaymentResultURL")
}

public extension NSNotification {
    static let didReceivePaymentResultURL = Notification.Name.didReceivePaymentResultURL
}
