// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

protocol TextFieldControllerDelegate: AnyObject {
    func textFieldDidBeginEditing()
    func textFieldDidEndEditing()
    func textFieldPrimaryActionTriggered()
    func textFieldDidBecomeFirstResponder()
    func textField(didChangeValueTo value: String)
}

extension Input.Table {
    class TextFieldController: NSObject {
        weak var delegate: TextFieldControllerDelegate?

        var model: (CellRepresentable & TextInputField & DefinesKeyboardStyle)? {
            didSet {
                guard let model = self.model else {
                    InternalError(description: "Model shouldn't be set to nil, programming error").log()
                    return
                }

                setModel(to: model)
            }
        }

        unowned let textInputView: TextInputView

        init(textInputView: TextInputView) {
            self.textInputView = textInputView
            super.init()

            textInputView.delegate = self

            textInputView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textInputView.textField.addTarget(self, action: #selector(textFieldPrimaryActionTriggered), for: .primaryActionTriggered)

            // Theming
            textInputView.textField.font = .preferredThemeFont(forTextStyle: .body)
            textInputView.titleLabel.font = .preferredThemeFont(forTextStyle: .footnote).withWeight(.semibold)
            textInputView.errorLabel.font = .preferredThemeFont(forTextStyle: .caption2)
        }

        @objc private func textFieldDidChange(_ textField: UITextField) {
            guard let model = self.model else { return }

            let text = textField.text ?? String()
            let value = model.patternFormatter?.formatter.unformat(text) ?? text

            delegate?.textField(didChangeValueTo: value)

            if let maxLength = model.maxInputLength, value.count >= maxLength {
                // Press primary action instead of an user when all characters were entered
                delegate?.textFieldPrimaryActionTriggered()
            }
        }

        @objc private func textFieldPrimaryActionTriggered() {
            delegate?.textFieldPrimaryActionTriggered()
        }
    }
}

extension Input.Table.TextFieldController {
    fileprivate func setModel(to model: CellRepresentable & TextInputField & DefinesKeyboardStyle) {
        if let inputFormatter = model.patternFormatter {
            textInputView.text = inputFormatter.formatter.format(model.value, addTrailingPattern: false)
        } else {
            textInputView.text = model.value
        }

        textInputView.setStatus(model.isEnabled ? .normal : .disabled)
        textInputView.titleLabel.text = model.label
        textInputView.textField.attributedPlaceholder = NSAttributedString(
            string: model.placeholder,
            attributes: [.foregroundColor: UIColor.themedDetailedText]
        )

        if let contentType = model.contentType {
            textInputView.textField.textContentType = contentType
        }

        textInputView.textField.keyboardType = model.keyboardType
        textInputView.textField.autocapitalizationType = model.autocapitalizationType
    }

    func setErrorText(to errorText: String?) {
        if let error = errorText {
            textInputView.setStatus(.error(message: error))
        } else {
            textInputView.setStatus(.normal)
        }
    }
}

// MARK: - UITextFieldDelegate

extension Input.Table.TextFieldController: TextInputViewDelegate {
    func textInputViewDidBeginEditing(_ view: TextInputView) {
        delegate?.textFieldDidBecomeFirstResponder()
    }

    func textInputViewDidEndEditing(_ view: TextInputView) {
        delegate?.textFieldDidEndEditing()
    }

    func textInputView(_ view: TextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let model = self.model else { return false }

        // Check if primary action was triggered.
        // Manual check required because we could return false in future steps and that will fail `primaryActionTriggered` UIKit call
        if string == "\n" {
            return true
        }

        // Create new full text string (replaced)
        let originText = textInputView.text
        let newFullString: String
        if let textRange = Range(range, in: originText) {
            newFullString = originText.replacingCharacters(in: textRange, with: string)
        } else {
            newFullString = .init()
        }

        // Strip special characters for validation purposes
        let replacedStringWithoutFormatting = model.patternFormatter?.formatter.unformat(newFullString) ?? newFullString

        // Validate if input contains only allowed chars
        guard containsOnlyAllowedCharacters(string: replacedStringWithoutFormatting, allowedKeyBoardType: textInputView.textField.keyboardType) else {
            return false
        }

        // Validate length
        if let maxLength = model.maxInputLength {
            // If use tries to insert a character(s) that exceeds max length
            guard replacedStringWithoutFormatting.count <= maxLength else {
                return false
            }
        }

        if let inputFormatter = model.patternFormatter {
            let formatted = inputFormatter.formatInput(replaceableString: .init(originText: originText, changesRange: range, replacementText: string))
            textInputView.textField.apply(formattedValue: formatted)

            // We need to call these manually because we're returning false so UIKit won't call that method
            textFieldDidChange(textInputView.textField)

            // We need to return false because we already changed the text via `textField.apply`
            return false
        } else {
            return true
        }
    }

    private func containsOnlyAllowedCharacters(string: String, allowedKeyBoardType: UIKeyboardType) -> Bool {
        guard let allowedCharacters = model?.allowedCharacters else {
            return true
        }

        return CharacterSet(charactersIn: string).isSubset(of: allowedCharacters)
    }
}

// MARK: - SupportsPrimaryAction

extension Input.Table.TextFieldController: SupportsPrimaryAction {
    func setPrimaryAction(to action: PrimaryAction) {
        switch action {
        case .next: textInputView.textField.returnKeyType = .next
        case .done: textInputView.textField.returnKeyType = .done
        }

        // Show input accessory view for number pads with "Next" button
        // We need that because number pads doesn't support display of a return key
        if textInputView.textField.keyboardType == .numberPad && UIDevice.current.userInterfaceIdiom != .pad {
            textInputView.textField.inputAccessoryView = createAccessoryView(for: action)
        } else {
            textInputView.textField.inputAccessoryView = nil
        }
    }

    private func createAccessoryView(for action: PrimaryAction) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let view = UIInputView(frame: frame, inputViewStyle: .default)

        let toolbar = UIToolbar(frame: frame)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let primaryAction: UIBarButtonItem

        switch action {
        case .next:
            let translationKey = "button.next.label"
            let title = model?.translator.translation(forKey: translationKey) ?? translationKey
            primaryAction = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(textFieldPrimaryActionTriggered))
        case .done: primaryAction = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(textFieldPrimaryActionTriggered))
        }

        toolbar.setItems([space, primaryAction], animated: false)

        // Layout
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        return view
    }
}

// MARK: -

private extension UITextField {
    func apply(formattedValue: FormattedTextValue) {
        self.text = formattedValue.formattedText

        if let cursorLocation = position(from: beginningOfDocument, offset: formattedValue.caretBeginOffset) {
            DispatchQueue.main.async {
                self.selectedTextRange = self.textRange(from: cursorLocation, to: cursorLocation)
            }
        }
    }
}
