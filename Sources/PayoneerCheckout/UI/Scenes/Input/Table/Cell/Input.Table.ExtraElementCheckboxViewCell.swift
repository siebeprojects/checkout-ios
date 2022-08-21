// Copyright (c) 2022 Payoneer Germany GmbH
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
    class ExtraElementCheckboxViewCell: UICollectionViewCell, ContainsInputCellDelegate, Dequeueable {
        weak var delegate: InputCellDelegate?

        private let checkboxView: CheckboxView
        private var model: Input.Field.ExtraElementCheckbox?

        override init(frame: CGRect) {
            checkboxView = CheckboxView(frame: .zero)

            super.init(frame: frame)

            checkboxView.valueDidChange = { [weak self] isOn in
                self?.checkboxValueDidChange(isOn: isOn)
            }

            configureLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Layout & initial configuration

private extension Input.Table.ExtraElementCheckboxViewCell {
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

extension Input.Table.ExtraElementCheckboxViewCell {
    func configure(with model: Input.Field.ExtraElementCheckbox) {
        checkboxView.isOn = model.isOn
        checkboxView.isEnabled = model.isEnabled
        checkboxView.switchAccessibilityIdentifier = model.id.textValue
        self.model = model

        // Configure text view
        if let font = checkboxView.font {
            let mutableString = NSMutableAttributedString(attributedString: model.label)
            mutableString.addAttributes([.font: font], range: NSRange(location: 0, length: mutableString.length))
            checkboxView.label = mutableString
        }

        // Validation
        if checkboxView.errorText != model.validationErrorText {
            if let errorText = model.validationErrorText {
                checkboxView.errorText = errorText
            } else {
                checkboxView.errorText = nil
            }
        }

        checkboxView.layoutSubviews()
    }
}

// MARK: - Value change handler

private extension Input.Table.ExtraElementCheckboxViewCell {
    func checkboxValueDidChange(isOn: Bool) {
        // If checkbox should be auto turned on
        if
            let model = self.model,
            case .forcedOn(let titleKey, let textKey) = model.isRequired
        {
            let title: String = model.translator.translation(forKey: titleKey)
            let text: String = model.translator.translation(forKey: textKey)

            var error = UIAlertController.AlertError(title: title, message: text)
            error.actions = [
                UIAlertController.Action(
                    label: .ok,
                    style: .default,
                    handler: { [checkboxView] _ in
                        checkboxView.isOn = true
                    }
                )
            ]

            let alertController = error.createAlertController(translator: model.translator)
            delegate?.present(alertController, animated: true, completion: nil)

            return
        }

        delegate?.inputCellValueDidChange(to: checkboxView.isOn.stringValue, cell: self)
        delegate?.inputCellDidEndEditing(cell: self)
    }
}
