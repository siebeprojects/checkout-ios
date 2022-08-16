// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit

extension Input.Field {
    class Checkbox {
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

extension Input.Field.Checkbox: WritableInputField {
    var value: String {
        get { isOn.stringValue }
        set { isOn = Bool(stringValue: newValue) ?? false }
    }
}

extension Input.Field.Checkbox: CellRepresentable {
    var cellType: (UICollectionViewCell & Dequeueable).Type { Input.Table.CheckboxViewCell.self }

    func configure(cell: UICollectionViewCell) throws {
        guard let checkboxViewCell = cell as? Input.Table.CheckboxViewCell else { throw errorForIncorrectView(cell) }
        checkboxViewCell.configure(with: self)
    }
}
