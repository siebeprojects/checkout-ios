#if canImport(UIKit)
import UIKit

extension Input {
    /// Cell that represents all text inputs, contains label and text field.
    /// Upon some actions calls `delegate`, don't forget to set it.
    ///
    /// - Warning: after initialization before using you have to set `indexPath` to cell's indexPath
    class TextFieldViewCell: UITableViewCell, DequeueableTableCell, ContainsInputCellDelegate {
        weak var delegate: InputCellDelegate?
        
        private let label: UILabel
        let textField: UITextField
        
        var indexPath: IndexPath!
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            label = .init(frame: .zero)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            
            textField = .init(frame: .zero)
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingDidEnd)
            
            contentView.addSubview(label)
            contentView.addSubview(textField)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -8),
                label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                label.widthAnchor.constraint(equalToConstant: 140),

                textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: 1),
                textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Input.TextFieldViewCell {
    override var canBecomeFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
            return textField.becomeFirstResponder()
    }
    
    func configure(with model: TextInputField & DefinesKeyboardStyle) {
        label.text = model.label
        textField.placeholder = model.placeholder
        textField.text = model.value

        textField.keyboardType = model.keyboardType
        textField.autocapitalizationType = model.autocapitalizationType
        
        if let contentType = model.contentType {
            textField.textContentType = contentType
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.inputCellValueDidChange(to: textField.text, at: indexPath)
    }
}

extension Input.TextFieldViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.inputCellBecameFirstResponder(at: indexPath)
    }
}
#endif
