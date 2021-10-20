// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Value could be reset to default state
protocol ResettableValue {
    var value: String { get set }
    var defaultValue: String { get }

    /// Set value to the default one
    mutating func resetValue()
}

extension ResettableValue {
    mutating func resetValue() {
        value = defaultValue
    }
}
