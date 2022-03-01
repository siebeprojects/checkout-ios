// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// A configuration object that defines the parameters for a `Checkout`.
@objc public class CheckoutConfiguration: NSObject {
    /// The URL contained in `links.self` on the response object from a create payment session request.
    public let listURL: URL

    /// The appearance settings to be used in the checkout UI. If not specified, a default appearance will be used.
    public let appearance: CheckoutAppearance

    /// Initializes a configuration object with the given parameters.
    /// - Parameters:
    ///   - listURL: The URL contained in `links.self` on the response object from a create payment session request.
    ///   - appearance: The appearance settings to be used in the checkout UI. If not specified, a default appearance will be used.
    @objc public init(listURL: URL, appearance: CheckoutAppearance = CheckoutAppearance()) {
        self.listURL = listURL
        self.appearance = appearance
    }
}
