// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension UIAlertController {
    static func unexpectedError() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: "Operation result and errorInfo is nil, it's a critical framework error.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        return alertController
    }
}
