// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// An object containing appearance-related settings for the checkout UI.
public struct CheckoutAppearance: Identifiable {
    public let id = UUID()

    /// The color of primary text, like titles and body.
    public let primaryTextColor: UIColor

    /// The color of secondary text, like subtitles and captions.
    public let secondaryTextColor: UIColor

    /// The background color of screens and views.
    public let backgroundColor: UIColor

    /// The accent color. On iOS this is the tint color. If `nil`, the host app's tint color is used.
    public let accentColor: UIColor?

    /// The color used to indicate errors. It's used in text fields.
    public let errorColor: UIColor

    /// The color of the borders and row separators on the payment list screen.
    public let borderColor: UIColor

    /// The color of the primary button's title.
    public let buttonTitleColor: UIColor

    /// An object responsible for providing the different variations of a custom font.
    public let fontProvider: CheckoutFontProvider

    /// The shared singleton appearance object. Initialized by `Checkout`.
    static var shared: CheckoutAppearance = .default

    /// The default appearance used if no custom appearance is set.
    public static var `default`: CheckoutAppearance {
        CheckoutAppearance(
            primaryTextColor: AssetProvider.primaryTextColor,
            secondaryTextColor: AssetProvider.secondaryTextColor,
            backgroundColor: AssetProvider.backgroundColor,
            accentColor: nil,
            errorColor: AssetProvider.errorColor,
            borderColor: AssetProvider.borderColor,
            buttonTitleColor: .white
        )
    }

    /// Initializes a `CheckoutAppearance` with the given parameters.
    /// - Parameters:
    ///   - primaryTextColor: The color of primary text, like titles and body.
    ///   - secondaryTextColor: The color of secondary text, like subtitles and captions.
    ///   - backgroundColor: The background color of screens and views.
    ///   - accentColor: The accent color. On iOS this is the tint color. If `nil`, the host app's tint color is used.
    ///   - errorColor: The color used to indicate errors. It's used in text fields.
    ///   - borderColor: The color of the borders and row separators on the payment list screen.
    ///   - buttonTitleColor: The color of the primary button's title.
    ///   - fontProvider: An object responsible for providing the different variations of a custom font. If not specified, the default system font will be used.
    public init(
        primaryTextColor: UIColor = CheckoutAppearance.default.primaryTextColor,
        secondaryTextColor: UIColor = CheckoutAppearance.default.secondaryTextColor,
        backgroundColor: UIColor = CheckoutAppearance.default.backgroundColor,
        accentColor: UIColor? = CheckoutAppearance.default.accentColor,
        errorColor: UIColor = CheckoutAppearance.default.errorColor,
        borderColor: UIColor = CheckoutAppearance.default.borderColor,
        buttonTitleColor: UIColor = CheckoutAppearance.default.buttonTitleColor,
        fontProvider: CheckoutFontProvider = CheckoutDefaultFontProvider()
    ) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.errorColor = errorColor
        self.borderColor = borderColor
        self.buttonTitleColor = buttonTitleColor
        self.fontProvider = fontProvider
    }
}

// MARK: - Equatable

extension CheckoutAppearance: Equatable {
    public static func == (lhs: CheckoutAppearance, rhs: CheckoutAppearance) -> Bool {
        lhs.id == rhs.id
    }
}
