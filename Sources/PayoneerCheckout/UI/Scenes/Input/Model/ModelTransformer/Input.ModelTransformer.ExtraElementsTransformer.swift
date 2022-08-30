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
        let translator: TranslationProvider

        func createInputField(from extraElement: ExtraElement) -> InputField? {
            if let checkbox = extraElement.checkbox {
                guard let inputFieldCheckbox = inputFieldCheckbox(for: checkbox, inside: extraElement) else { return nil }
                return inputFieldCheckbox
            }

            let label = label(for: extraElement)
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
            let isRequired: Input.Field.ExtraElementCheckbox.Requirement
            let requiredMessage = checkbox.requiredMessage ?? extraElement.name + "." + "requiredMessage"

            // Reference: https://optile.atlassian.net/wiki/spaces/PPW/pages/3391881231/ExtraElement+Checkbox+modes
            switch checkboxMode {
            case .OPTIONAL:
                isOn = false
                isRequired = .notRequired
            case .OPTIONAL_PRESELECTED:
                isOn = true
                isRequired = .notRequired
            case .REQUIRED:
                isOn = false
                isRequired = .required(requiredMessage: requiredMessage)
            case .REQUIRED_PRESELECTED:
                isOn = true
                isRequired = .required(requiredMessage: requiredMessage)
            case .FORCED, .FORCED_DISPLAYED:
                // Reference: https://optile.atlassian.net/browse/PCX-3383 (point 4)
                isOn = true
                isRequired = .forcedOn(
                    titleKey: "messages.checkbox.forced.title",
                    textKey: "messages.checkbox.forced.text"
                )
            }

            let label = label(for: extraElement)

            let checkbox = Input.Field.ExtraElementCheckbox(extraElementName: extraElement.name, isOn: isOn, label: label, isRequired: isRequired, translator: translator)

            return checkbox
        }

        func label(for extraElement: ExtraElement) -> NSAttributedString {
            let markdownParser = MarkdownParser()
            return markdownParser.parse(extraElement.label)
        }
    }
}

extension Input.ModelTransformer.ExtraElementTransformer: Loggable {}
