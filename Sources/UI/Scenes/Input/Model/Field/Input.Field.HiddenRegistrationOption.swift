// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Field {
    /// Label with no user interaction and pre-set value for registration options.
    final class HiddenRegistrationOption: Hidden, ResettableValue {
        let defaultValue: String

        override init(id: Identifier, value: String) {
            self.defaultValue = value
            super.init(id: id, value: value)
        }
    }
}
