// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// An object containing appearance-related settings for the checkout UI.
@objc public class CheckoutAppearance: NSObject {
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let errorColor: UIColor

    // TODO: Use correct colors

    /// Initializes a `CheckoutAppearance` with the given parameters.
    @objc public init(
        primaryTextColor: UIColor = .black,
        secondaryTextColor: UIColor = .gray,
        errorColor: UIColor = .red
    ) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.errorColor = errorColor
    }
}
