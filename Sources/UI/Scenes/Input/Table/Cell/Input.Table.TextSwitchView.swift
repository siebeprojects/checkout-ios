// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Table {
    class TextSwitchView: UIView, Loggable {
        fileprivate let textView: UIView
        fileprivate let switchControl: UISwitch

        var checkboxValueDidChangeBlock: ((Bool) -> Void)?

        init(frame: CGRect, textView: UIView) {
            self.textView = textView
            self.switchControl = .init(frame: frame)

            super.init(frame: frame)

            addViews()

            // Configure checkbox
            switchControl.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc private func switchValueDidChange(_ sender: UISwitch) {
            guard let checkboxValueDidChangeBlock = self.checkboxValueDidChangeBlock else {
                if #available(iOS 14.0, *) {
                    logger.error("CheckboxValueDidChangeBlock is not set but value was changed")
                }

                return
            }

            checkboxValueDidChangeBlock(sender.isOn)
        }
    }
}

// MARK: - Setup views

extension Input.Table.TextSwitchView {
    fileprivate func addViews() {
        addSubview(textView)
        addSubview(switchControl)

        setupConstraints()
    }

    private func setupConstraints() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false

        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        switchControl.setContentHuggingPriority(.defaultLow, for: .vertical)

        let bottomLabelConstraint = textView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomLabelConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -.defaultInterviewSpacing),
            bottomLabelConstraint,
            textView.topAnchor.constraint(equalTo: self.topAnchor),

            switchControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            switchControl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            switchControl.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            switchControl.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor)
        ])
    }
}

// MARK: - Configure with model

extension Input.Table.TextSwitchView {
    func configureSwitch(with model: Input.Field.Checkbox) {
        switchControl.isOn = model.isOn
        switchControl.onTintColor = self.tintColor
        switchControl.isEnabled = model.isEnabled
    }
}

// MARK: - Constants

private extension CGFloat {
    static var defaultInterviewSpacing: CGFloat { 8 }
}
