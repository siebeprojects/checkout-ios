// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

/// The default font provider. It returns the system font for the preferred style or combination of size and weight.
public struct CheckoutDefaultFontProvider: CheckoutFontProvider {
    public func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        return UIFont.preferredFont(forTextStyle: textStyle)
    }

    public func font(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: weight)
    }

    public init() {}
}
