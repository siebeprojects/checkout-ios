// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Table {
    /// Cell that represents a checkbox (UISwitch) with a text view with clickable links.
    ///
    /// Don't forget to set `delegate`.
    final class TextViewSwitchViewCell: UICollectionViewCell, DequeueableCell {
        weak var delegate: InputCellDelegate?

        fileprivate let textView: UITextView
        fileprivate let textSwitchView: TextSwitchView

        override init(frame: CGRect) {
            let textView = UITextView(frame: .zero)
            self.textView = textView
            textSwitchView = .init(frame: .zero, textView: textView)

            super.init(frame: frame)

            // Configure text view
            textView.textColor = .themedText
            textView.font = UIFont.preferredThemeFont(forTextStyle: .body)

            // Setup text switch view
            addTextSwitchView()

            textSwitchView.checkboxValueDidChangeBlock = { [weak self] isOn in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.inputCellValueDidChange(to: isOn.stringValue, cell: weakSelf)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Input.Table.TextViewSwitchViewCell {
    fileprivate func addTextSwitchView() {
        contentView.addSubview(textSwitchView)
        setupConstraints()
    }

    private func setupConstraints() {
        textSwitchView.translatesAutoresizingMaskIntoConstraints = false
        let bottomLabelConstraint = textSwitchView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomLabelConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            textSwitchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textSwitchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLabelConstraint,
            textSwitchView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }
}

// MARK: - Cell configuration

extension Input.Table.TextViewSwitchViewCell {
    func configure(with model: Input.Field.Checkbox) {
        textView.attributedText = model.label
        textSwitchView.configureSwitch(with: model)
    }
}

extension Input.Table.TextViewSwitchViewCell: ContainsInputCellDelegate {}
