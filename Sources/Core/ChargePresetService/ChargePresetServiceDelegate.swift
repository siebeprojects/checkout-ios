// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

@objc public protocol ChargePresetDelegate {
    @objc func chargePresetService(didReceivePaymentResult paymentResult: PaymentResult, viewController: UIViewController?)
    @objc func chargePresetService(didRequestPresenting viewController: UIViewController)
}
