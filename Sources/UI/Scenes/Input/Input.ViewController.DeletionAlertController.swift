// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.ViewController {
    struct DeletionAlert {
        private let translator: TranslationProvider

        private let title, message: String
        private var deleteAction: UIAlertAction?

        /// Initialize `UIAlertController` with added message, title and cancel button.
        /// - Note: don't forget to call `addDeleteAction(handler:)` to add a delete button
        /// - Parameters:
        ///   - translator: translator that will be used to translate message, title and buttons
        ///   - accountLabel: account label (e.g. `VISA **** 2021`) that will be used in a message
        init(translator: TranslationProvider, accountLabel: String) {
            self.translator = translator
            
            self.title = translator.translation(forKey: "accounts.delete.title")

            // Message comes with replacable variable
            var message: String = translator.translation(forKey: "accounts.delete.text")
            message = message.replacingOccurrences(of: "${account.displayLabel}", with: accountLabel)
            self.message = message
        }
        
        /// Add a translated delete action.
        mutating func setDeleteAction(handler: ((UIAlertAction) -> Void)?) {
            let deleteText: String? = translator.translation(forKey: "button.delete.label")
            self.deleteAction = UIAlertAction(title: deleteText, style: .destructive, handler: handler)
        }

        func createAlertController() -> UIAlertController {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let cancelText: String? = translator.translation(forKey: "button.cancel.label")
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            if let deleteAction = self.deleteAction {
                alertController.addAction(deleteAction)
            }

            return alertController
        }
    }
}
