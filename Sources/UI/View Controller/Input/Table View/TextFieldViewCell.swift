#if canImport(UIKit)
import UIKit

class TextFieldViewCell: UITableViewCell, DequeueableTableCell {
    private let label: UILabel
    private let textField: UITextField
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        label = .init(frame: .zero)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        textField = .init(frame: .zero)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        contentView.addSubview(textField)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.layoutMarginsGuide.leadingAnchor, constant: -8),
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
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
            return textField.becomeFirstResponder()
    }
    
    func configure(with model: TextInputField & DefinesKeyboardStyle) {
        label.text = model.label
        textField.placeholder = model.placeholder

        textField.keyboardType = model.keyboardType
        textField.autocapitalizationType = model.autocapitalizationType
        
        if let contentType = model.contentType {
            textField.textContentType = contentType
        }
    }
}
#endif
