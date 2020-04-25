#if canImport(UIKit)
import UIKit
import MaterialComponents.MaterialTextFields

extension CGFloat {
    static let cellVerticalSpacing: CGFloat = 8
}

extension Input.Table {
    /// Cell that represents all text inputs, contains label and text field.
    /// Upon some actions calls `delegate`, don't forget to set it.
    ///
    /// - Warning: after initialization before using you have to set `indexPath` to cell's indexPath
    class TextFieldViewCell: UITableViewCell, DequeueableTableCell, ContainsInputCellDelegate {
        weak var delegate: InputCellDelegate?

        private let textField: MDCTextField
        fileprivate let textFieldController: MDCTextInputControllerFilled

        private(set) var model: (TextInputField & DefinesKeyboardStyle)!

        var indexPath: IndexPath!

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            textField = .init()
            textFieldController = .init(textInput: textField)
            textField.leadingUnderlineLabel.numberOfLines = 0
            textField.leadingUnderlineLabel.lineBreakMode = .byWordWrapping

            super.init(style: style, reuseIdentifier: reuseIdentifier)

            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(textFieldPrimaryActionTriggered), for: .primaryActionTriggered)

            contentView.addSubview(textField)

            textField.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .cellVerticalSpacing / 2),
                contentView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: .cellVerticalSpacing / 2)
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

        textField.tintColor = self.tintColor
        textFieldController.activeColor = textField.tintColor
        textFieldController.floatingPlaceholderActiveColor = textField.tintColor
        textFieldController.leadingUnderlineLabelTextColor = textField.tintColor

        textFieldController.textInputFont = .preferredFont(forTextStyle: .body)
        textFieldController.inlinePlaceholderFont = textFieldController.textInputFont

        textFieldController.placeholderText = model.label
        textField.text = model.formatProcessor?.format(string: model.value) ?? model.value

        textField.keyboardType = model.keyboardType
        textField.autocapitalizationType = model.autocapitalizationType

        if let contentType = model.contentType {
            textField.textContentType = contentType
        }

        showValidationResult(for: model)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let value: String?
        if let text = textField.text, let unformattedString = model.formatProcessor?.clear(formattingFromString: text) {
            value = unformattedString
        } else {
            value = textField.text
        }
        
        if let length = value?.count, let maxLength = model.maxInputLength, length >= maxLength {
            // Press primary action instead of an user when all characters were entered
            delegate?.inputCellPrimaryActionTriggered(at: indexPath)
        }
        
        delegate?.inputCellValueDidChange(to: value, at: indexPath)
    }

    @objc fileprivate func textFieldPrimaryActionTriggered() {
        delegate?.inputCellPrimaryActionTriggered(at: indexPath)
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
        delegate?.inputCellBecameFirstResponder(at: indexPath)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldController.setHelperText(nil, helperAccessibilityLabel: nil)
        delegate?.inputCellDidEndEditing(at: indexPath)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if primary action was triggered.
        // Manual check required because we could return false in future steps and that will fail `primaryActionTriggered` UIKit call
        if string == "\n" {
            return true
        }

        // Strip special characters for validation purposes
        let replaceableString = Input.ReplaceableString(origin: textField.text ?? String(), changesRange: range, replacement: string)
        let replacedStringWithoutFormatting = model.formatProcessor?.clear(formattingFromString: replaceableString.replacing()) ?? String()
        
        guard containsOnlyAllowedCharacters(string: replacedStringWithoutFormatting, allowedKeyBoardType: textField.keyboardType) else {
            return false
        }
        
        if let maxLength = model.maxInputLength {
            // If use tries to insert a character(s) that exceeds max length
            guard replacedStringWithoutFormatting.count <= maxLength else {
                return false
            }
        }

        if let processor = model.formatProcessor {
            let formatter = TextFormatter(processor: processor)
            let formatted = formatter.format(string: textField.text ?? String(), shouldChangeCharactersIn: range, replacementString: string)

            textField.apply(formattedString: formatted)

            // We need to call these manually because we're returning false so UIKit won't call that method
            textFieldDidChange(textField)

            // We need to return false because we already changed the text via `textField.apply`
            return false
        } else {
            return true
        }
    }

    private func containsOnlyAllowedCharacters(string: String, allowedKeyBoardType: UIKeyboardType) -> Bool {
        let allowed: CharacterSet
        switch allowedKeyBoardType {
        case .numbersAndPunctuation:
            var set = CharacterSet.decimalDigits
            set.formUnion(CharacterSet(charactersIn: " -"))
            allowed = set
        case .numberPad:
            allowed = .decimalDigits
        default: return true
        }

        if CharacterSet(charactersIn: string).isSubset(of: allowed) {
            return true
        } else {
            return false
        }
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
        let view = UIInputView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 44), inputViewStyle: .default)

        let toolbar = UIToolbar()
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
#endif
