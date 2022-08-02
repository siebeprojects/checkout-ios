// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit
import Logging

extension Input.Field {
    class ExtraElementCheckbox: Checkbox, Loggable {
        /// Indicates if checkbox have to be checked, otherwhise it should lead to validation error
        let isRequired: Requirement

        // MARK: Validatable

        var validationErrorText: String?

        // MARK: Initializer

        init(extraElementName: String, isOn: Bool, label: NSAttributedString, isRequired: Requirement) {
            self.isRequired = isRequired

            super.init(id: .extraElement(extraElementName), isOn: isOn, label: label)
        }
    }
}

extension Input.Field.ExtraElementCheckbox {
    enum Requirement {
        case notRequired
        case required(requiredMessage: String)
    }
}

extension Input.Field.ExtraElementCheckbox: Validatable {
    func localize(error: Input.Field.Validation.ValidationError) -> String {
        switch isRequired {
        case .notRequired:
            if #available(iOS 14.0, *) {
                logger.error("ExtraElementCheckbox is not required but got validation error, programmatic error. Name=\(self.id.textValue)")
            }
            return String()
        case .required(let requiredMessage):
            return requiredMessage
        }
    }

    var validationRule: Input.Field.Validation.Rule? { return nil }

    func validate(using option: Input.Field.Validation.Option) -> Input.Field.Validation.Result {
        switch isRequired {
        case .notRequired:
            return .success
        case .required:
            return isOn ? .success : .failure(.invalidValue)
        }
    }
}
