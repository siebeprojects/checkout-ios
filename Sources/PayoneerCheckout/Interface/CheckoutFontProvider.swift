// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// The protocol used to create a custom font provider.
@objc public protocol CheckoutFontProvider {
    /// Returns an instance of the custom font for the specified text style with scaling for the user's selected content size category.
    /// - Returns: The custom font associated with the specified text style.
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont

    /// Returns the custom font object for standard interface items in the specified size and weight.
    /// - Returns: A font object of the specified size and weight.
    func font(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont
}
