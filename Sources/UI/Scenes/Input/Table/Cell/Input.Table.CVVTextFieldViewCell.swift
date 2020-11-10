import UIKit
import MaterialComponents.MaterialTextFields

protocol CVVTextFieldViewCellDelegate: class {
    func presentHint(viewController: UIViewController)
}

extension Input.Table {
    class CVVTextFieldViewCell: TextFieldViewCell {
        weak var cvvDelegate: CVVTextFieldViewCellDelegate?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let button = UIButton()
            button.setImage(AssetProvider.iconCVVQuestionMark, for: .normal)
            button.addTarget(self, action: #selector(testAction), for: .touchUpInside)
            
            textField.rightView = button
            textField.rightViewMode = .always
        }
        
        @objc private func testAction() {
            let alertController = UIAlertController(title: "test", message: "message", preferredStyle: .alert)
            cvvDelegate?.presentHint(viewController: alertController)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
