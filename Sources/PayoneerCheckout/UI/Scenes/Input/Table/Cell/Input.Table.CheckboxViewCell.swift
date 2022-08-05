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

        private let textView: UITextView
        let checkbox: UISwitch
        weak var errorLabel: UILabel?

        // FIXME: Temporary value, show be checked in another place not show/hide validation errors multiple times
        private var validationError: String?

        override init(frame: CGRect) {
            textView = .init(frame: .zero)
            checkbox = .init(frame: .zero)

            super.init(frame: frame)

            configureTextView()
            checkbox.addTarget(self, action: #selector(checkboxValueChanged), for: .valueChanged)
            configureLayout()
        }

        @objc private func checkboxValueChanged(_ sender: UISwitch) {
            delegate?.inputCellValueDidChange(to: checkbox.isOn.stringValue, cell: self)
            delegate?.inputCellDidEndEditing(cell: self)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Layout & initial configuration

private extension Input.Table.CheckboxViewCell {
    func configureTextView() {
        textView.textColor = CheckoutAppearance.shared.primaryTextColor
        textView.font = CheckoutAppearance.shared.fontProvider.font(forTextStyle: .subheadline)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.adjustsFontForContentSizeCategory = true

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        textView.delegate = self
    }

    func configureLayout() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        checkbox.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textView)
        contentView.addSubview(checkbox)

        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        checkbox.setContentHuggingPriority(.defaultLow, for: .vertical)

        // TextView should be center if it contains only a single line (`centerY` with low priority, )
        // If TextView contains multiple ones it follow

        NSLayoutConstraint.activate([
            // Textview
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -UIConstant.defaultSpacing),

            textView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            {
                let centerY = textView.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor)
                centerY.priority = .defaultLow
                return centerY
            }(),
            {
                let bottom = textView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
                bottom.priority = .defaultHigh
                return bottom
            }(),

            // Checkbox
            checkbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            checkbox.topAnchor.constraint(equalTo: contentView.topAnchor),
            checkbox.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: - Configure with model

extension Input.Table.CheckboxViewCell {
    func configure(with model: Input.Field.Checkbox) {
        checkbox.isOn = model.isOn
        checkbox.isEnabled = model.isEnabled
        checkbox.accessibilityIdentifier = model.id.textValue

        // Configure text view
        if let font = textView.font {
            let mutableString = NSMutableAttributedString(attributedString: model.label)
            mutableString.addAttributes([.font: font], range: NSRange(location: 0, length: mutableString.length))
            textView.attributedText = mutableString
        }

        // Validation
        if let validatableModel = model as? Validatable, validationError != validatableModel.validationErrorText {
            self.validationError = validatableModel.validationErrorText

            if let errorText = validatableModel.validationErrorText {
                showValidationError(text: errorText)
            } else {
                removeValidationError()
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension Input.Table.CheckboxViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        typealias BrowserController = Input.ViewController.BrowserController

        NotificationCenter.default.post(name: BrowserController.userDidClickLinkInPaymentView, object: nil, userInfo: [BrowserController.linkUserInfoKey: URL])
        return false
    }
}

// MARK: - Validation

private extension Input.Table.CheckboxViewCell {
    func showValidationError(text: String) {
        let errorLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.font = CheckoutAppearance.shared.fontProvider.font(forTextStyle: .caption2)
            label.textColor = CheckoutAppearance.shared.errorColor
            label.numberOfLines = 0
            label.adjustsFontForContentSizeCategory = true
            label.text = text
            return label
        }()
        self.errorLabel = errorLabel

        contentView.addSubview(errorLabel)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: UIConstant.defaultSpacing),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func removeValidationError() {
        errorLabel?.removeFromSuperview()
        errorLabel = nil
    }
}
