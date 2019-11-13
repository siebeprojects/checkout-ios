#if canImport(UIKit)
import UIKit

class InputTableViewCell: UITableViewCell, DequeueableTableCell {
    weak var textField: UITextField?
    weak var label: UILabel?
    
    var inputField: InputField! {
        didSet {
            configure(with: inputField)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField?.becomeFirstResponder() ?? false
    }
    
    private func configure(with inputField: InputField) {
        // Create views
        let textField = InputTextField(inputField: inputField)
        textField.placeholder = inputField.placeholder
        self.textField = textField
        
        let label = UILabel(frame: .zero)
        label.text = inputField.label
        self.label = label
        
        addSubviews(textField: textField, label: label)
    }
    
    private func addSubviews(textField: UITextField, label: UILabel) {
        // Add subviews
        contentView.addSubview(label)
        contentView.addSubview(textField)
        
        // Set constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.widthAnchor.constraint(equalToConstant: 120),
            
            textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        ])
    }
}
#endif
