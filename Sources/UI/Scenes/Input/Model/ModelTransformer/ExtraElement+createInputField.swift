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
            return Input.Field.Label(label: self.label, name: self.name, value: true.stringValue)
        case .FORCED:
            return Input.Field.Hidden(name: self.name, value: true.stringValue)
        // Case: checkbox property is not present
        case .none:
            // TODO: Should be defined in the next ticket if we should sent any value in POST request if there is no checkbox or it is not displayed
            return Input.Field.Label(label: self.label, name: self.name, value: false.stringValue)
        }

        return Input.Field.TextViewCheckbox(name: self.name, isOn: isOn, label: self.label)
    }
}
