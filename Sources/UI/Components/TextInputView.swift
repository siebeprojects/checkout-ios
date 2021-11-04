// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

// TODO: These will be replaced when implemented in the project
private let titleColor: UIColor = .darkGray
private let borderColorIdle: UIColor = .gray
private let borderColorDisabled: UIColor = .lightGray
private let containerBackgroundColor: UIColor = .white
private let textColor: UIColor = .black
private let errorColor: UIColor = .red

/// The text input component.
final class TextInputView: UIView {
    /// The different possible statuses of the component.
    enum Status: Equatable {
        case normal
        case error(message: String)
        case disabled
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = titleColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()

    private let textFieldContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 2
        view.layer.borderColor = borderColorIdle.cgColor
        view.backgroundColor = containerBackgroundColor
        return view
    }()

    // TODO: This should be private
    let textField: UITextField = {
        let field = UITextField()
        field.adjustsFontForContentSizeCategory = true
        field.font = .preferredFont(forTextStyle: .body)
        field.textColor = textColor
        field.placeholder = "Placeholder"
        field.clearButtonMode = .never
        return field
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = errorColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.isHidden = true
        return label
    }()

    private let trailingButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(trailingButtonAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    /// The text displayed in the component.
    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    private var status: Status = .normal

    private weak var delegate: TextInputViewDelegate?

    /// Initializes a `TextInputView` with a given title and placeholder, and an optional button image and delegate.
    /// - Parameters:
    ///   - title: The title displayed above the component.
    ///   - placeholder: The placeholder text displayed inside the component when text is empty.
    ///   - trailingButtonImage: An optional image for the trailing button. The button is shown or hidden based on this value.
    ///   - delegate: The delegate of the `TextInputView`.
    required init(title: String? = nil, placeholder: String? = nil, trailingButtonImage: UIImage? = nil, delegate: TextInputViewDelegate?) {
        super.init(frame: .zero)
        configure(title: title, placeholder: placeholder, trailingButtonImage: trailingButtonImage, delegate: delegate)
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
    }
}

// MARK: - Configuration

extension TextInputView {
    /// Configures a `TextInputView` with a given title and placeholder, and an optional button image and delegate.
    /// - Parameters:
    ///   - title: The title displayed above the component.
    ///   - placeholder: The placeholder text displayed inside the component when text is empty.
    ///   - trailingButtonImage: An optional image for the trailing button. The button is shown or hidden based on this value.
    ///   - delegate: The delegate of the `TextInputView`.
    func configure(title: String? = nil, placeholder: String? = nil, trailingButtonImage: UIImage? = nil, delegate: TextInputViewDelegate?) {
        self.delegate = delegate
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.delegate = self

        trailingButton.setImage(trailingButtonImage, for: .normal)
        trailingButton.isHidden = trailingButton.currentImage == nil
    }

    /// Switches the `TextInputView` to the given `status`, with an option to animate the change.
    /// - Parameters:
    ///   - status: The status to be displayed.
    ///   - animated: `true` if you want to animate the change, and `false` if it should be immediate.
    func setStatus(_ status: Status, animated: Bool = true) {
        self.status = status
        isUserInteractionEnabled = status != .disabled
        updateAppearance(animated: animated)
    }

    private func updateAppearance(animated: Bool) {
        // If a label is in a UIStackView and its text is set to nil, the label is automatically hidden by the UIStackView.
        // This mechanic breaks the show/hide animations being done here, therefore errorMessage can't be optional and an empty string is used instead.
        let configuration: (borderColor: UIColor, errorMessage: String) = {
            switch status {
            case .normal:
                return (isFirstResponder ? tintColor : borderColorIdle, "")
            case .error(let message):
                return (errorColor, message)
            case .disabled:
                return (borderColorDisabled, "")
            }
        }()

        textFieldContainerView.layer.setBorderColor(configuration.borderColor, animated: animated)
        errorLabel.text = configuration.errorMessage

        let shouldHideError = configuration.errorMessage.isEmpty

        let changes = { [weak self] in
            self?.alpha = self?.status == .disabled ? 0.5 : 1
            self?.errorLabel.isHiddenInStackView = shouldHideError
            self?.errorLabel.alpha = shouldHideError ? 0 : 1
            self?.errorLabel.superview?.layoutIfNeeded()
        }

        if animated {
            animate(changes)
        } else {
            changes()
        }
    }
}

// MARK: - Layout

extension TextInputView {
    private func layout() {
        backgroundColor = .clear

        trailingButton.setContentHuggingPriority(.required, for: .horizontal)
        trailingButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textFieldButtonStackView = UIStackView(arrangedSubviews: [textField, trailingButton])

        textFieldContainerView.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: 12, vertical: 0)
        textFieldButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainerView.addSubview(textFieldButtonStackView)
        textFieldButtonStackView.fitToSuperview(obeyMargins: true)
        textFieldButtonStackView.addConstraint(
            NSLayoutConstraint(
                item: textFieldButtonStackView,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 48
            )
        )

        let stackView = UIStackView(arrangedSubviews: [titleLabel, textFieldContainerView, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.fitToSuperview()
    }
}

// MARK: - Interaction

extension TextInputView {
    override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    @objc private func trailingButtonAction(_ sender: UIButton) {
        delegate?.textInputViewDidTapTrailingButton(self)
    }
}

// MARK: - UITextFieldDelegate

extension TextInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let shouldAnimate = textField.frame != .zero // Prevent animation while view is being laid out
        updateAppearance(animated: shouldAnimate)
        delegate?.textInputViewDidBeginEditing(self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setStatus(.normal)
        return delegate?.textInputView(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textInputViewShouldReturn(self) ?? false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAppearance(animated: true)
        delegate?.textInputViewDidEndEditing(self)
    }
}
