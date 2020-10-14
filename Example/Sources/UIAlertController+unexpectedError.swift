import UIKit

extension UIAlertController {
    static func unexpectedError() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Operation result and errorInfo is nil, it's a critical framework error.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        return alertController
    }
}
