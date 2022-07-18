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
    ///
    /// - Warning: after initialization before using you have to set `indexPath` to cell's indexPath
    class CheckboxViewCell: UICollectionViewCell, Dequeueable {
        weak var delegate: InputCellDelegate?

        private let textView: UITextView
        let checkbox: UISwitch

        override init(frame: CGRect) {
            textView = .init(frame: .zero)
            checkbox = .init(frame: .zero)

            super.init(frame: frame)

            // Configure a text view
            textView.textColor = CheckoutAppearance.shared.primaryTextColor
            textView.font = CheckoutAppearance.shared.fontProvider.font(forTextStyle: .subheadline)
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.adjustsFontForContentSizeCategory = true

            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0

            textView.delegate = self

            // Configure checkbox
            checkbox.addTarget(self, action: #selector(checkboxValueChanged), for: .valueChanged)

            // Layout
            textView.translatesAutoresizingMaskIntoConstraints = false
            checkbox.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(textView)
            contentView.addSubview(checkbox)

            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            checkbox.setContentHuggingPriority(.defaultLow, for: .vertical)

            let bottomtextViewConstraint = textView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor)
            bottomtextViewConstraint.priority = .defaultHigh

            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -UIConstant.defaultSpacing),
                textView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                textView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
                bottomtextViewConstraint,

                checkbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                checkbox.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
                checkbox.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor)
            ])
        }

        @objc private func checkboxValueChanged(_ sender: UISwitch) {
            delegate?.inputCellValueDidChange(to: checkbox.isOn.stringValue, cell: self)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Cell configuration

extension Input.Table.CheckboxViewCell {
    func configure(with model: Input.Field.Checkbox) {
        checkbox.isOn = model.isOn
        checkbox.onTintColor = self.tintColor
        checkbox.isEnabled = model.isEnabled

        // Configure text view
        if let font = textView.font {
            let mutableString = NSMutableAttributedString(attributedString: model.label)
            mutableString.addAttributes([.font: font], range: NSRange(location: 0, length: mutableString.length))
            textView.attributedText = mutableString
        }
    }
}

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

extension Input.Table.CheckboxViewCell: ContainsInputCellDelegate {}
