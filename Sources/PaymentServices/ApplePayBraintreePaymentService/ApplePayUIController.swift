// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import PassKit
import BraintreeApplePay

class ApplePayUIController: NSObject {
    private(set) weak var paymentViewController: PKPaymentAuthorizationViewController?

    private var didAuthorizePaymentBlock: ((PKPayment) -> Void)?

    /// Handler from `paymentAuthorizationViewController`
    var applePayViewControllerHandler: ((PKPaymentAuthorizationResult) -> Void)?

    func createPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest, didAuthorizePayment: @escaping ((PKPayment) -> Void)) throws -> PKPaymentAuthorizationViewController {
        guard let paymentViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            throw PaymentError(errorDescription: "Unable to create PKPaymentAuthorizationViewController because PKPaymentRequest may be invalid")
        }

        self.didAuthorizePaymentBlock = didAuthorizePayment

        self.paymentViewController = paymentViewController
        paymentViewController.delegate = self
        return paymentViewController
    }
}

extension ApplePayUIController: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.applePayViewControllerHandler = completion
        didAuthorizePaymentBlock?(payment)
    }
}
