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

            let id = Input.Field.Identifier.extraElement(extraElement.name)

            // Reference: https://optile.atlassian.net/wiki/spaces/PPW/pages/3391881231/ExtraElement+Checkbox+modes
            switch checkboxMode {
            case .OPTIONAL, .REQUIRED:
                return .init(id: id, isOn: false, label: label)
            case .OPTIONAL_PRESELECTED, .REQUIRED_PRESELECTED:
                return .init(id: id, isOn: true, label: label)
            case .FORCED, .FORCED_DISPLAYED:
                // Reference: https://optile.atlassian.net/browse/PCX-3383 (point 4)
                let checkbox = Input.Field.Checkbox(id: id, isOn: true, label: label)
                checkbox.isEnabled = false
                return checkbox
            }
        }

        private var label: NSAttributedString {
            let markdownParser = MarkdownParser()
            return markdownParser.parse(extraElement.label)
        }
    }
}

extension Input.ModelTransformer.ExtraElementTransformer: Loggable {}
