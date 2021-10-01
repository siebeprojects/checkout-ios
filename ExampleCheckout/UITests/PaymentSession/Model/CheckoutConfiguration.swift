//
//  CheckoutConfiguration.swift
//  UITests
//
//  Created by Caio Araujo on 01.10.21.
//  Copyright © 2021 Payoneer Germany GmbH. All rights reserved.
//

import Foundation

enum CheckoutConfiguration: String {
    case extraElementsTopBottom = "UITests-ExtraElements-TopBottom"
    case extraElementsTop = "UITests-ExtraElements-Top"
    case extraElementsBottom = "UITests-ExtraElements-Bottom"

    var name: String {
        rawValue
    }
}
