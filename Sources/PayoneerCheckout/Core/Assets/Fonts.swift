// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

private enum Fonts {
    static func mainFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        .preferredFont(forTextStyle: textStyle)
    }

    static func mainFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        .systemFont(ofSize: fontSize, weight: weight)
    }
}

final class DefaultFontProvider: CheckoutFontProviderProtocol {
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        return Fonts.mainFont(forTextStyle: textStyle)
    }

    func font(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        return Fonts.mainFont(ofSize: fontSize, weight: weight)
    }
}
