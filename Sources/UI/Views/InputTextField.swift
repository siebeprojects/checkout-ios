#if canImport(UIKit)
import UIKit

class InputTextField: UITextField {
    let inputField: InputField
    
    init(inputField: InputField) {
        self.inputField = inputField
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
