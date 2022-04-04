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
    public let backgroundColor: UIColor
    public let accentColor: UIColor?
    public let errorColor: UIColor
    public let borderColor: UIColor
    public let buttonTitleColor: UIColor
    public let fontProvider: CheckoutFontProviderProtocol

    /// The shared singleton appearance object. Initialized by `Checkout`.
    static var shared: CheckoutAppearance = .default

    @objc public static var `default`: CheckoutAppearance {
        CheckoutAppearance(
            primaryTextColor: Colors.primaryText,
            secondaryTextColor: Colors.secondaryText,
            backgroundColor: Colors.background,
            accentColor: nil,
            errorColor: Colors.error,
            borderColor: Colors.border,
            buttonTitleColor: .white
        )
    }

    /// Initializes a `CheckoutAppearance` with the given parameters.
    @objc public init(
        primaryTextColor: UIColor = CheckoutAppearance.default.primaryTextColor,
        secondaryTextColor: UIColor = CheckoutAppearance.default.secondaryTextColor,
        backgroundColor: UIColor = CheckoutAppearance.default.backgroundColor,
        accentColor: UIColor? = CheckoutAppearance.default.accentColor,
        errorColor: UIColor = CheckoutAppearance.default.errorColor,
        borderColor: UIColor = CheckoutAppearance.default.borderColor,
        buttonTitleColor: UIColor = CheckoutAppearance.default.buttonTitleColor,
        fontProvider: CheckoutFontProviderProtocol? = nil
    ) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.errorColor = errorColor
        self.borderColor = borderColor
        self.buttonTitleColor = buttonTitleColor
        self.fontProvider = fontProvider ?? DefaultFontProvider()
    }
}
