// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

public typealias CheckoutResultBlock = (_ result: CheckoutResult) -> Void

/// <#Description#>
@objc public class Checkout: NSObject {
    private let configuration: CheckoutConfiguration
    private weak var presenter: UIViewController?

    /// <#Description#>
    /// - Parameters:
    ///   - configuration: <#configuration description#>
    ///   - delegate: <#delegate description#>
    @objc public init(configuration: CheckoutConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - Operations

@objc public extension Checkout {
    /// <#Description#>
    /// - Parameter presenter: <#presenter description#>
    /// - Parameter completion: <#completion description#>
    func presentPaymentList(from presenter: UIViewController, _ completion: CheckoutResultBlock) {

    }

    /// <#Description#>
    /// - Parameter completion: <#completion description#>
    func chargePresetAccount(_ completion: CheckoutResultBlock) {

    }

    /// <#Description#>
    /// - Parameter completion: <#completion description#>
    func dismiss(_ completion: (() -> Void)? = nil) {
        presenter?.dismiss(animated: true, completion: completion)
    }
}
