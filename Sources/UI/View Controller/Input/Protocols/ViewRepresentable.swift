#if canImport(UIKit)
import UIKit

protocol ViewRepresentable {
    func createView() -> UIView
}

// MARK: - TextInputField

extension ViewRepresentable where Self: TextInputField {
    func createView() -> UIView {
        let contentView = UIView()
        
        let label = UILabel(frame: .zero)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = self.label
        contentView.addSubview(label)
        
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        
        if let definesKeyboardStyle = self as? DefinesKeyboardStyle {
            textField.keyboardType = definesKeyboardStyle.keyboardType
            textField.autocapitalizationType = definesKeyboardStyle.autocapitalizationType
            
            if let contentType = definesKeyboardStyle.contentType {
                textField.textContentType = contentType
            }
        }
        contentView.addSubview(textField)
        
        // Set constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.widthAnchor.constraint(equalToConstant: 140),

            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 1),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        return contentView
    }
}
#endif
