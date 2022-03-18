// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

enum Fonts {
    static func mainFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        .preferredFont(forTextStyle: textStyle)
    }

    static func mainFont(forTextStyle textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let font = mainFont(forTextStyle: textStyle)
        let descriptor = font.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }
}
