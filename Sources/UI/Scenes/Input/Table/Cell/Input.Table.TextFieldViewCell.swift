#if canImport(UIKit)
import UIKit
import MaterialComponents.MaterialTextFields

extension Input.Table {
    /// Cell that represents all text inputs, contains label and text field.
    /// Upon some actions calls `delegate`, don't forget to set it.
    ///
    /// - Warning: after initialization before using you have to set `indexPath` to cell's indexPath
    class TextFieldViewCell: FullWidthCollectionViewCell, DequeueableCell, ContainsInputCellDelegate {
        weak var delegate: InputCellDelegate?

        private let textField: MDCTextField
        fileprivate let textFieldController: MDCTextInputControllerFilled

        private(set) var model: (TextInputField & DefinesKeyboardStyle)!

        override init(frame: CGRect) {
            textField = .init()
            textFieldController = .init(textInput: textField)
            textField.leadingUnderlineLabel.numberOfLines = 0
            textField.leadingUnderlineLabel.lineBreakMode = .byWordWrapping

            super.init(frame: frame)

            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldPrimaryActionTriggered), for: .primaryActionTriggered)

            contentView.addSubview(textField)

            textField.translatesAutoresizingMaskIntoConstraints = false
            
            let textFieldBottomAnchor = contentView.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
            textFieldBottomAnchor.priority = .defaultHigh
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                textField.topAnchor.constraint(equalTo: contentView.topAnchor),
                textFieldBottomAnchor
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Cell configuration

extension Input.Table.TextFieldViewCell {
    override var canBecomeFirstResponder: Bool { return true }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }

    func configure(with model: TextInputField & DefinesKeyboardStyle) {
        self.model = model

        if let inputFormatter = model.patternFormatter {
            textField.text = inputFormatter.formatter.format(model.value, addTrailingPattern: false)
        } else {
            textField.text = model.value
        }

        textField.tintColor = self.tintColor
        textFieldController.activeColor = textField.tintColor
        textFieldController.floatingPlaceholderActiveColor = textField.tintColor
        textFieldController.leadingUnderlineLabelTextColor = textField.tintColor

        textFieldController.textInputFont = .preferredFont(forTextStyle: .body)
        textFieldController.inlinePlaceholderFont = textFieldController.textInputFont

        textFieldController.placeholderText = model.label

        if let contentType = model.contentType {
            textField.textContentType = contentType
        }

        textField.keyboardType = model.keyboardType
        textField.autocapitalizationType = model.autocapitalizationType
        
        showValidationResult(for: model)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? String()
        let value = model.patternFormatter?.formatter.unformat(text) ?? text

        delegate?.inputCellValueDidChange(to: value, cell: self)
        
        if let maxLength = model.maxInputLength, value.count >= maxLength {
            // Press primary action instead of an user when all characters were entered
            delegate?.inputCellPrimaryActionTriggered(cell: self)
        }
    }

    @objc fileprivate func textFieldPrimaryActionTriggered() {
        delegate?.inputCellPrimaryActionTriggered(cell: self)
    }
}

// MARK: - Validation error label

extension Input.Table.TextFieldViewCell {
    func showValidationResult(for model: Any) {
        guard let model = model as? Validatable else { return }

        if let errorText = model.validationErrorText {
            showErrorLabel(withText: errorText)
        } else {
            removeErrorLabel()
        }
    }

    private func showErrorLabel(withText: String) {
        textFieldController.setErrorText(withText, errorAccessibilityValue: nil)
    }

    private func removeErrorLabel() {
        textFieldController.setErrorText(nil, errorAccessibilityValue: nil)
    }
}

// MARK: - UITextFieldDelegate

extension Input.Table.TextFieldViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldController.setHelperText(model.placeholder, helperAccessibilityLabel: model.placeholder)
        delegate?.inputCellBecameFirstResponder(cell: self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layoutIfNeeded()
        textFieldController.setHelperText(nil, helperAccessibilityLabel: nil)
        delegate?.inputCellDidEndEditing(cell: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if primary action was triggered.
        // Manual check required because we could return false in future steps and that will fail `primaryActionTriggered` UIKit call
        if string == "\n" {
            return true
        }

        // Make new full text string (replaced)
        let originText = textField.text ?? String()
        let newFullString: String
        if let textRange = Range(range, in: originText) {
            newFullString = originText.replacingCharacters(in: textRange, with: string)
        } else {
            newFullString = .init()
        }

        // Strip special characters for validation purposes
        let replacedStringWithoutFormatting = model.patternFormatter?.formatter.unformat(newFullString) ?? newFullString

        // Validate if input contains only allowed chars
        guard containsOnlyAllowedCharacters(string: replacedStringWithoutFormatting, allowedKeyBoardType: textField.keyboardType) else {
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
            textField.apply(formattedValue: formatted)

            // We need to call these manually because we're returning false so UIKit won't call that method
            textFieldDidChange(textField)

            // We need to return false because we already changed the text via `textField.apply`
            return false
        } else {
            return true
        }
    }

    private func containsOnlyAllowedCharacters(string: String, allowedKeyBoardType: UIKeyboardType) -> Bool {
        guard let allowedCharacters = model.allowedCharacters else {
            return true
        }
        
        return CharacterSet(charactersIn: string).isSubset(of: allowedCharacters)
    }
}

// MARK: - SupportsPrimaryAction

extension Input.Table.TextFieldViewCell: SupportsPrimaryAction {
    func setPrimaryAction(to action: PrimaryAction) {
        switch action {
        case .next: textField.returnKeyType = .next
        case .done: textField.returnKeyType = .done
        }

        // Show input accessory view for number pads with "Next" button
        // We need that because number pads doesn't support display of a return key
        if textField.keyboardType == .numberPad && UIDevice.current.userInterfaceIdiom != .pad {
            textField.inputAccessoryView = makeAccessoryView(for: action)
        } else {
            textField.inputAccessoryView = nil
        }
    }

    private func makeAccessoryView(for action: PrimaryAction) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let view = UIInputView(frame: frame, inputViewStyle: .default)

        let toolbar = UIToolbar(frame: frame)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let primaryAction: UIBarButtonItem

        switch action {
        case .next: primaryAction = UIBarButtonItem(title: model.translator.translation(forKey: LocalTranslation.next.rawValue), style: .plain, target: self, action: #selector(textFieldPrimaryActionTriggered))
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
#endif
