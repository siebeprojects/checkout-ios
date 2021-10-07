// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

enum CheckoutConfiguration: String {
    case extraElementsTopBottom = "UITests-ExtraElements-TopBottom"
    case extraElementsTop = "UITests-ExtraElements-Top"
    case extraElementsBottom = "UITests-ExtraElements-Bottom"

    var name: String {
        rawValue
    }
}
