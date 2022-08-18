// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import Logging

extension Input.ModelTransformer {
    struct ExtraElementTransformer {
        let extraElement: ExtraElement

        var inputField: InputField? {
            if let checkbox = extraElement.checkbox {
                guard let inputFieldCheckbox = inputFieldCheckbox(for: checkbox, inside: extraElement) else { return nil }
                return inputFieldCheckbox
            }

            return Input.Field.Label(label: label, id: .inputElementName(extraElement.name), value: "")
        }

        private func inputFieldCheckbox(for checkbox: Checkbox, inside extraElement: ExtraElement) -> Input.Field.Checkbox? {
            guard let checkboxMode = Checkbox.Mode(rawValue: checkbox.mode) else {
                if #available(iOS 14.0, *) {
                    logger.error("Checkbox mode is not defined for name=\(extraElement.name), skipping checkbox.")
                }

                return nil
            }

            let isOn: Bool
            let isRequiredMode: Bool
            var isEnabled = true

            // Reference: https://optile.atlassian.net/wiki/spaces/PPW/pages/3391881231/ExtraElement+Checkbox+modes
            switch checkboxMode {
            case .OPTIONAL:
                isOn = false
                isRequiredMode = false
            case .OPTIONAL_PRESELECTED:
                isOn = true
                isRequiredMode = false
            case .REQUIRED:
                isOn = false
                isRequiredMode = true
            case .REQUIRED_PRESELECTED:
                isOn = true
                isRequiredMode = true
            case .FORCED, .FORCED_DISPLAYED:
                // Reference: https://optile.atlassian.net/browse/PCX-3383 (point 4)
                isOn = true
                isRequiredMode = true
                isEnabled = false
            }

            let isRequired: Input.Field.ExtraElementCheckbox.Requirement = {
                if !isRequiredMode { return .notRequired }
                let requiredMessage = checkbox.requiredMessage ?? extraElement.name + "." + "requiredMessage"
                return .required(requiredMessage: requiredMessage)
            }()

            let checkbox = Input.Field.ExtraElementCheckbox(extraElementName: extraElement.name, isOn: isOn, label: label, isRequired: isRequired)
            checkbox.isEnabled = isEnabled

            return checkbox
        }

        private var label: NSAttributedString {
            let markdownParser = MarkdownParser()
            return markdownParser.parse(extraElement.label)
        }
    }
}

extension Input.ModelTransformer.ExtraElementTransformer: Loggable {}
