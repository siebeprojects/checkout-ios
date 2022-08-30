// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

private struct UIConstant {
    static let defaultSpacing: CGFloat = 8
}

final class CheckboxView: UIView {
    private let textView: UITextView
    private let checkbox: UISwitch
    private weak var errorLabel: UILabel?

    weak var delegate: CheckboxViewDelegate?

    var isOn: Bool {
        get { checkbox.isOn }
        set { checkbox.setOn(newValue, animated: true) }
    }

    var label: NSAttributedString {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }

    var isEnabled: Bool {
        get { checkbox.isEnabled }
        set { checkbox.isEnabled = newValue }
    }

    var switchAccessibilityIdentifier: String? {
        get { checkbox.accessibilityIdentifier }
        set { checkbox.accessibilityIdentifier = newValue }
    }

    var font: UIFont? { textView.font }

    var errorText: String? {
        didSet {
            if let errorText = errorText {
                showValidationError(text: errorText)
            } else {
                removeValidationError()
            }
        }
    }

    override init(frame: CGRect) {
        textView = .init(frame: .zero)
        checkbox = .init(frame: .zero)

        super.init(frame: frame)

        configureTextView()
        checkbox.addTarget(self, action: #selector(checkboxValueChanged), for: .valueChanged)
        configureLayout()
    }

    @objc private func checkboxValueChanged(_ sender: UISwitch) {
        delegate?.checkboxView(self, valueDidChangeTo: sender.isOn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout & initial configuration

private extension CheckboxView {
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

        addSubview(textView)
        addSubview(checkbox)

        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        checkbox.setContentHuggingPriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            // Textview
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -UIConstant.defaultSpacing),

            textView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            {
                let centerY = textView.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor)
                centerY.priority = .defaultLow
                return centerY
            }(),
            {
                let bottom = textView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
                bottom.priority = .defaultHigh
                return bottom
            }(),

            // Checkbox
            checkbox.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkbox.topAnchor.constraint(equalTo: topAnchor),
            checkbox.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
}

// MARK: - Configure with model

extension CheckboxView {
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
        if let validatableModel = model as? Validatable, errorLabel?.text != validatableModel.validationErrorText {
            if let errorText = validatableModel.validationErrorText {
                showValidationError(text: errorText)
            } else {
                removeValidationError()
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension CheckboxView: UITextViewDelegate {
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

extension CheckboxView {
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

        addSubview(errorLabel)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: UIConstant.defaultSpacing),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func removeValidationError() {
        errorLabel?.removeFromSuperview()
        errorLabel = nil
    }
}
