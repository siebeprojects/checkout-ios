// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Field {
    /// Label with no user interaction and pre-set value.
    class Label {
        let label: NSAttributedString
        let id: Identifier
        var value: String

        var isEnabled: Bool = true

        init(label: NSAttributedString, id: Identifier, value: String) {
            self.label = label
            self.id = id
            self.value = value
        }
    }
}

extension Input.Field.Label: InputField, CellRepresentable {
    var cellType: (UICollectionViewCell & Dequeueable).Type { Input.Table.LabelViewCell.self }

    func configure(cell: UICollectionViewCell) throws {
        guard let labelCell = cell as? Input.Table.LabelViewCell else { throw errorForIncorrectView(cell) }
        labelCell.configure(with: self)
    }
}
