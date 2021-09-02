// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension ExtraElement {
    func createInputField() -> InputField {
        let isOn: Bool

        switch self.checkbox?.checkboxMode {
        case .OPTIONAL, .REQUIRED: isOn = false
        case .OPTIONAL_PRESELECTED, .REQUIRED_PRESELECTED: isOn = true
        case .FORCED_DISPLAYED:
            return Input.Field.Label(label: NSAttributedString(markdown: label), name: self.name, value: true.stringValue)
        case .FORCED:
            return Input.Field.Hidden(name: self.name, value: true.stringValue)
        // Case: checkbox property is not present
        case .none:
            return Input.Field.Label(label: NSAttributedString(markdown: label), name: self.name, value: false.stringValue)
        }

        return Input.Field.Checkbox(name: self.name, isOn: isOn, label: NSAttributedString(markdown: label))
    }
}
