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
        let name: String
        var isOn: Bool
        var isEnabled: Bool = true

        let label: NSAttributedString

        init(name: String, isOn: Bool, label: NSAttributedString) {
            self.name = name
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
    var cellType: (UICollectionViewCell & DequeueableCell).Type {
        if label.contains(attribute: .link) {
            return Input.Table.LabelSwitchViewCell.self
        } else {
            return Input.Table.TextViewSwitchViewCell.self
        }
    }

    func configure(cell: UICollectionViewCell) throws {
        switch cell {
        case let labelCell as Input.Table.LabelSwitchViewCell: labelCell.configure(with: self)
        case let textViewCell as Input.Table.TextViewSwitchViewCell: textViewCell.configure(with: self)
        default: throw errorForIncorrectView(cell)
        }
    }
}

private extension NSAttributedString {
    func contains(attribute: NSAttributedString.Key) -> Bool {
        return attributes(at: 0, effectiveRange: nil).contains { $0.key == attribute }
    }
}
