// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// <#Description#>
@objc public class CheckoutConfiguration: NSObject {
    /// <#Description#>
    public let paymentListURL: URL
    /// <#Description#>
    public let appearance: CheckoutAppearance

    /// <#Description#>
    /// - Parameters:
    ///   - paymentListURL: <#paymentListURL description#>
    ///   - appearance: <#appearance description#>
    @objc public init(paymentListURL: URL, appearance: CheckoutAppearance) {
        self.paymentListURL = paymentListURL
        self.appearance = appearance
    }
}
