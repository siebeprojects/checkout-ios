// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import PayoneerCheckout

private let regularFontName = "Rubik-Regular"
private let boldFontName = "Rubik-Bold"

final class CustomFontProvider: CheckoutFontProviderProtocol {
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        let customFont: UIFont? = {
            switch textStyle {
            case .largeTitle:  return UIFont(name: regularFontName, size: 34)!
            case .title1:      return UIFont(name: regularFontName, size: 28)!
            case .title2:      return UIFont(name: regularFontName, size: 22)!
            case .title3:      return UIFont(name: regularFontName, size: 20)!
            case .headline:    return UIFont(name: boldFontName, size: 17)
            case .body:        return UIFont(name: regularFontName, size: 17)!
            case .callout:     return UIFont(name: regularFontName, size: 16)!
            case .subheadline: return UIFont(name: regularFontName, size: 15)!
            case .footnote:    return UIFont(name: regularFontName, size: 13)!
            case .caption1:    return UIFont(name: regularFontName, size: 12)!
            case .caption2:    return UIFont(name: regularFontName, size: 11)!
            default:           return nil
            }
        }()

        guard let customFont = customFont else { return .preferredFont(forTextStyle: textStyle) }

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
