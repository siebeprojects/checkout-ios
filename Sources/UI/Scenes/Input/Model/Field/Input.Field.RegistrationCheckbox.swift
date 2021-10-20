// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit

extension Input.Field {
    final class RegistrationCheckbox: Checkbox, ResettableValue {
        let defaultValue: String

        override init(id: Identifier, isOn: Bool, label: NSAttributedString) {
            self.defaultValue = isOn.stringValue
            super.init(id: id, isOn: isOn, label: label)
        }
    }
}
