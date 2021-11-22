// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

private let titleColor: UIColor = .themedText
private let borderColorIdle: UIColor = titleColor
private let borderColorDisabled: UIColor = borderColorIdle.withAlphaComponent(0.5)
private let containerBackgroundColor: UIColor = .themedBackground
private let textColor: UIColor = .themedText
private let errorColor: UIColor = .themedError
private let borderWidthIdle: CGFloat = 1
private let borderWidthHighlighted: CGFloat = 2

/// The text input component.
final class TextInputView: UIView {
    /// The different possible statuses of the component.
    enum Status: Equatable {
        case normal
        case error(message: String)
        case disabled
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = titleColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()

    private let textFieldContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderWidth = borderWidthIdle
        view.layer.borderColor = borderColorIdle.cgColor
        view.backgroundColor = containerBackgroundColor
        return view
    }()

    let textField: UITextField = {
        let field = UITextField()
        field.textColor = textColor
        field.clearButtonMode = .never
        return field
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = errorColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.isHidden = true
        return label
    }()

    let trailingButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        return button
    }()

    /// The text displayed in the component.
    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    private let shouldAnimate: Bool

    private var status: Status = .normal

    weak var delegate: TextInputViewDelegate?

    /// Initializes a `TextInputView`.
    /// - Parameter animationsEnabled: `true` if you want to animate appearance changes, and `false` if they should be immediate.
    required init(animationsEnabled: Bool) {
        shouldAnimate = animationsEnabled
        super.init(frame: .zero)
        textField.delegate = self
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        shouldAnimate = true
        super.init(coder: aDecoder)
        textField.delegate = self
        layout()
    }
}

// MARK: - State

extension TextInputView {
    /// Switches the `TextInputView` to the given `status`, with an option to animate the change.
    /// - Parameters:
    ///   - status: The status to be displayed.
    func setStatus(_ status: Status) {
        self.status = status
        isUserInteractionEnabled = status != .disabled
        updateAppearance(animated: shouldAnimate)
    }

    private func updateAppearance(animated: Bool) {
        // If a label is in a UIStackView and its text is set to nil, the label is automatically hidden by the UIStackView.
        // This mechanic breaks the show/hide animations being done here, therefore errorMessage can't be optional and an empty string is used instead.
        let configuration: (borderColor: UIColor, borderWidth: CGFloat, errorMessage: String) = {
            switch status {
            case .normal:
                return (
                    borderColor: isFirstResponder ? tintColor : borderColorIdle,
                    borderWidth: isFirstResponder ? borderWidthHighlighted : borderWidthIdle,
                    errorMessage: ""
                )
            case .error(let message):
                return (
                    borderColor: errorColor,
                    borderWidth: borderWidthHighlighted,
                    errorMessage: message
                )
            case .disabled:
                return (
                    borderColor: borderColorDisabled,
                    borderWidth: borderWidthIdle,
                    errorMessage: ""
                )
            }
        }()

        textFieldContainerView.layer.setBorderColor(configuration.borderColor, animated: animated)
        textFieldContainerView.layer.setBorderWidth(configuration.borderWidth, animated: animated)
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

        // Add tap gesture to entire view to facilitate interaction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGesture)

        // Add padding to match the clear button's padding
        trailingButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6.5)

        let textFieldButtonStackView = UIStackView(arrangedSubviews: [textField, trailingButton])
        textFieldButtonStackView.alignment = .center
        textFieldButtonStackView.spacing = 4

        textFieldContainerView.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: 12, vertical: 14)
        textFieldButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainerView.addSubview(textFieldButtonStackView)
        textFieldButtonStackView.fitToSuperview(obeyMargins: true)

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
        return textField.becomeFirstResponder()
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        becomeFirstResponder()
    }

    @objc private func trailingButtonAction(_ sender: UIButton) {
        delegate?.textInputViewDidTapTrailingButton(self)
    }
}

// MARK: - UITextFieldDelegate

extension TextInputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateAppearance(animated: shouldAnimate && textField.frame != .zero) // Prevent animation while view is being laid out
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
        updateAppearance(animated: shouldAnimate)
        delegate?.textInputViewDidEndEditing(self)
    }
}
