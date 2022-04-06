// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout

private let regularFontName = "Rubik-Regular"
private let boldFontName = "Rubik-Bold"

final class CustomFontProvider: CheckoutFontProvider {
    private let fontVariants: [UIFont.TextStyle: UIFont] = [
        .largeTitle: UIFont(name: regularFontName, size: 34)!,
        .title1: UIFont(name: regularFontName, size: 28)!,
        .title2: UIFont(name: regularFontName, size: 22)!,
        .title3: UIFont(name: regularFontName, size: 20)!,
        .headline: UIFont(name: boldFontName, size: 17)!,
        .body: UIFont(name: regularFontName, size: 17)!,
        .callout: UIFont(name: regularFontName, size: 16)!,
        .subheadline: UIFont(name: regularFontName, size: 15)!,
        .footnote: UIFont(name: regularFontName, size: 13)!,
        .caption1: UIFont(name: regularFontName, size: 12)!,
        .caption2: UIFont(name: regularFontName, size: 11)!
    ]

    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        guard let customFont = fontVariants[textStyle] else {
            return .preferredFont(forTextStyle: textStyle)
        }

        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: customFont)
    }

    func font(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .ultraLight, .thin, .light, .regular:
            return UIFont(name: regularFontName, size: fontSize)!

        case .medium, .semibold, .bold, .heavy, .black:
            return UIFont(name: boldFontName, size: fontSize)!

        default:
            return .systemFont(ofSize: fontSize, weight: weight)
        }
    }
}
