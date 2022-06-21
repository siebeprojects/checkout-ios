// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import PassKit

class ApplePayUIController: NSObject {
    func createPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest) throws -> PKPaymentAuthorizationViewController {
        guard let paymentViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            throw PaymentError(errorDescription: "Unable to create PKPaymentAuthorizationViewController because PKPaymentRequest may be invalid")
        }
        paymentViewController.delegate = self
        return paymentViewController
     }
}

extension ApplePayUIController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        controller.dismiss(animated: true)
    }
}
