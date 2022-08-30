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

        let translator: TranslationProvider

        // MARK: Validatable

        var validationErrorText: String?

        // MARK: Initializer

        init(extraElementName: String, isOn: Bool, label: NSAttributedString, isRequired: Requirement, translator: TranslationProvider) {
            self.isRequired = isRequired
            self.translator = translator

            super.init(id: .extraElement(extraElementName), isOn: isOn, label: label)
        }

        // MARK: CellRepresentable

        override var cellType: (UICollectionViewCell & Dequeueable).Type {
            Input.Table.ExtraElementCheckboxViewCell.self
        }

        override func configure(cell: UICollectionViewCell) throws {
            guard let checkboxViewCell = cell as? Input.Table.ExtraElementCheckboxViewCell else {
                throw errorForIncorrectView(cell)
            }

            checkboxViewCell.configure(with: self)
        }
    }
}

extension Input.Field.ExtraElementCheckbox {
    enum Requirement {
        case notRequired

        /// Checkbox is required to be on and if user toggles it off validation error should be displayed.
        /// - Important: requiredMessage is localized string received from a server.
        case required(requiredMessage: String)

        /// Checkbox is forced to be on. If user toggles checkbox off it should be automatically turned back on and validation message is shown.
        /// - Important: associated values are localization keys, not localized Strings.
        case forcedOn(titleKey: String, textKey: String)
    }
}

extension Input.Field.ExtraElementCheckbox: Validatable {
    func localize(error: Input.Field.Validation.ValidationError) -> String {
        switch isRequired {
        case .notRequired, .forcedOn:
            if #available(iOS 14.0, *) {
                logger.error("ExtraElementCheckbox shouldn't be validated but was asked for validation error, programmatic error. Name=\(self.id.textValue)")
            }
            return String()
        case .required(let requiredMessage):
            return requiredMessage
        }
    }

    var validationRule: Input.Field.Validation.Rule? {
        return nil
    }

    func validate(using option: Input.Field.Validation.Option) -> Input.Field.Validation.Result {
        switch isRequired {
        case .notRequired:
            return .success
        case .required, .forcedOn:
            return isOn ? .success : .failure(.invalidValue)
        }
    }
}
