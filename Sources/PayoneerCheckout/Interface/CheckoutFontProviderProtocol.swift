// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

@objc public protocol CheckoutFontProviderProtocol {
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont
    func font(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont
}
