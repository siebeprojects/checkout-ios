// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// An object containing appearance-related settings for the checkout UI.
@objc public class CheckoutAppearance: NSObject {
    public let font: UIFont
    public let primaryTextColor: UIColor
    public let secondaryTextColor: UIColor
    public let backgroundColor: UIColor
    public let accentColor: UIColor
    public let errorColor: UIColor
    public let borderColor: UIColor
    public let buttonTitleColor: UIColor

    /// Initializes a `CheckoutAppearance` with the given parameters.
    @objc public init(
        font: UIFont? = nil,
        primaryTextColor: UIColor? = nil,
        secondaryTextColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        accentColor: UIColor? = nil,
        errorColor: UIColor? = nil,
        borderColor: UIColor? = nil,
        buttonTitleColor: UIColor? = nil
    ) {
        self.font = font ?? .preferredFont(forTextStyle: .body)
        self.primaryTextColor = primaryTextColor ?? Colors.primaryText
        self.secondaryTextColor = secondaryTextColor ?? Colors.secondaryText
        self.backgroundColor = backgroundColor ?? Colors.background
        self.accentColor = accentColor ?? Colors.accent
        self.errorColor = errorColor ?? Colors.error
        self.borderColor = borderColor ?? Colors.border
        self.buttonTitleColor = buttonTitleColor ?? .white
    }
}
