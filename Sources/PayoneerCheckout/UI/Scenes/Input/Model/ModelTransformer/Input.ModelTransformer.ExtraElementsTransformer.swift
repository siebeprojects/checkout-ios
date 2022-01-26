// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ModelTransformer {
    struct ExtraElementsTransformer {
        func createInputField(from extraElement: ExtraElement) -> InputField? {
            guard extraElement.checkbox == nil else {
                if #available(iOS 14.0, *) {
                    logger.debug("Skipping extra element \(extraElement.name) because it has a checkbox")
                }

                return nil
            }

            let markdownParser = MarkdownParser()
            let parsedLabel = markdownParser.parse(extraElement.label)
            return Input.Field.Label(label: parsedLabel, id: .inputElementName(extraElement.name), value: "")
        }
    }
}

extension Input.ModelTransformer.ExtraElementsTransformer: Loggable {}
