// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

final class MockCheckoutPresenter: UIViewController {
    private(set) var presentCalled = false
    private(set) var dismissCalled = false
    private(set) var presented: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presented = viewControllerToPresent
        presentCalled = true
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
        completion?()
    }
}
