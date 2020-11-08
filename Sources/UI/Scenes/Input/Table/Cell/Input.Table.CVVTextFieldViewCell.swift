import UIKit
import MaterialComponents.MaterialTextFields

extension Input.Table {
    class CVVTextFieldViewCell: TextFieldViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let button = UIButton()
            button.setImage(AssetProvider.iconCVVQuestionMark, for: .normal)
            
            textField.rightView = button
            textField.rightViewMode = .always
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
