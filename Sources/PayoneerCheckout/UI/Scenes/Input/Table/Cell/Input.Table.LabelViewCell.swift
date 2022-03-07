// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Table {
    /// Cell that represents a text label.
    class LabelViewCell: UICollectionViewCell, Dequeueable {
        fileprivate let textView: UITextView

        override init(frame: CGRect) {
            textView = .init(frame: .zero)

            super.init(frame: frame)

            // Configure a text view
            textView.textColor = .themedText
            textView.font = UIFont.preferredThemeFont(forTextStyle: .subheadline)
            textView.isScrollEnabled = false
            textView.isEditable = false

            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0

            textView.delegate = self

            // Layout
            contentView.addSubview(textView)

            textView.translatesAutoresizingMaskIntoConstraints = false

            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let bottomtextViewConstraint = textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            bottomtextViewConstraint.priority = .defaultHigh

            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bottomtextViewConstraint,
                textView.topAnchor.constraint(equalTo: contentView.topAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Cell configuration

extension Input.Table.LabelViewCell {
    func configure(with model: Input.Field.Label) {
        textView.isUserInteractionEnabled = model.isEnabled

        // Configure text view
        if let font = textView.font {
            let mutableString = NSMutableAttributedString(attributedString: model.label)
            mutableString.addAttributes([.font: font], range: NSRange(location: 0, length: mutableString.length))
            textView.attributedText = mutableString
        }
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        typealias BrowserController = Input.ViewController.BrowserController

        NotificationCenter.default.post(name: BrowserController.userDidClickLinkInPaymentView, object: nil, userInfo: [BrowserController.linkUserInfoKey: URL])
        return false
    }
}

extension Input.Table.LabelViewCell: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
