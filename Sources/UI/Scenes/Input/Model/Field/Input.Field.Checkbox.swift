// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit

extension Input.Field.Checkbox {
    struct Constant {
        static var allowRegistration: String { "allowRegistration" }
        static var allowRecurrence: String { "allowRecurrence" }
    }
}

extension Input.Field {
    final class Checkbox {
        let id: Identifier
        var isOn: Bool
        var isEnabled: Bool = true

        let label: NSAttributedString

        init(id: Identifier, isOn: Bool, label: NSAttributedString) {
            self.id = id
            self.isOn = isOn
            self.label = label
        }
    }
}

extension Input.Field.Checkbox: InputField {
    var value: String {
        get { isOn.stringValue }
        set {
            guard let newBoolean = Bool(stringValue: newValue) else {
                InternalError(description: "Tried to set boolean from unexpected string value: %@", newValue).log()
                return
            }

            isOn = newBoolean
        }
    }
}

extension Input.Field.Checkbox: CellRepresentable {
    var cellType: (UICollectionViewCell & DequeueableCell).Type { Input.Table.CheckboxViewCell.self }

    func configure(cell: UICollectionViewCell) throws {
        guard let checkboxViewCell = cell as? Input.Table.CheckboxViewCell else { throw errorForIncorrectView(cell) }
        checkboxViewCell.configure(with: self)
    }
}
