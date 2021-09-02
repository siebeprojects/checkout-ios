// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Table {
    /// Cell that represents a textView.
    class LabelViewCell: UICollectionViewCell, DequeueableCell {
        fileprivate let textView: UITextView

        override init(frame: CGRect) {
            textView = .init(frame: .zero)

            super.init(frame: frame)

            // Configure a text view
            textView.textColor = .themedText
            textView.font = UIFont.preferredThemeFont(forTextStyle: .body)
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.isSelectable = false

            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0

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
        let mutableString = NSMutableAttributedString(attributedString: model.label)
        mutableString.addAttributes([.font: UIFont.preferredThemeFont(forTextStyle: .body)], range: NSRange(location: 0, length: mutableString.length))
        textView.attributedText = mutableString
    }
}
