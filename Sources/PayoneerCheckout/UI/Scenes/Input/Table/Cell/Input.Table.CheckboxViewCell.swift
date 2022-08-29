// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

private struct UIConstant {
    static let defaultSpacing: CGFloat = 8
}

extension Input.Table {
    /// Cell that represents a checkbox (UISwitch).
    /// Upon some actions calls `delegate`, don't forget to set it.
    class CheckboxViewCell: UICollectionViewCell, ContainsInputCellDelegate, Dequeueable {
        weak var delegate: InputCellDelegate?

        private let checkboxView: CheckboxView

        override init(frame: CGRect) {
            checkboxView = CheckboxView(frame: .zero)

            super.init(frame: frame)

            checkboxView.delegate = self
            configureLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Layout & initial configuration

private extension Input.Table.CheckboxViewCell {
    func configureLayout() {
        checkboxView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(checkboxView)

        NSLayoutConstraint.activate([
            checkboxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkboxView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            checkboxView.topAnchor.constraint(equalTo: contentView.topAnchor),
            {
                let bottomConstraint = checkboxView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                bottomConstraint.priority = .defaultLow
                return bottomConstraint
            }()
        ])
    }
}

// MARK: - Configure with model

extension Input.Table.CheckboxViewCell {
    func configure(with model: Input.Field.Checkbox) {
        checkboxView.isOn = model.isOn
        checkboxView.isEnabled = model.isEnabled
        checkboxView.switchAccessibilityIdentifier = model.id.textValue

        // Configure text view
        if let font = checkboxView.font {
            let mutableString = NSMutableAttributedString(attributedString: model.label)
            mutableString.addAttributes([.font: font], range: NSRange(location: 0, length: mutableString.length))
            checkboxView.label = mutableString
        }

        // Validation
        if let validatableModel = model as? Validatable, checkboxView.errorText != validatableModel.validationErrorText {
            if let errorText = validatableModel.validationErrorText {
                checkboxView.errorText = errorText
            } else {
                checkboxView.errorText = nil
            }
        }

        checkboxView.layoutSubviews()
    }
}

// MARK: - CheckboxViewDelegate

extension Input.Table.CheckboxViewCell: CheckboxViewDelegate {
    func checkboxView(_ view: CheckboxView, valueDidChangeTo isOn: Bool) {
        delegate?.inputCellValueDidChange(to: checkboxView.isOn.stringValue, cell: self)
        delegate?.inputCellDidEndEditing(cell: self)
    }
}
