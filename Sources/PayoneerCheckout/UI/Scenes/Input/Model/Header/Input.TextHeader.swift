// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Foundation

extension Input {
    final class TextHeader {
        let logo: UIImage?
        let label: String
        var detailedLabel: String?
        var isEnabled: Bool = true

        init(logo: UIImage?, label: String) {
            self.logo = logo
            self.label = label
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from registeredAccount: UIModel.RegisteredAccount) {
            self.init(logo: registeredAccount.logo?.value, label: registeredAccount.maskedAccountLabel)

            let maskedAccount = registeredAccount.apiModel.maskedAccount
            if let expiryMonth = maskedAccount.expiryMonth, let expiryYear = maskedAccount.expiryYear {
                detailedLabel = Self.createExpiryLabel(expiryMonth: expiryMonth, expiryYear: expiryYear)
            }
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from presetAccount: UIModel.PresetAccount) {
            self.init(logo: presetAccount.logo?.value, label: presetAccount.maskedAccountLabel)

            let maskedAccount = presetAccount.apiModel.maskedAccount
            if let expiryMonth = maskedAccount?.expiryMonth, let expiryYear = maskedAccount?.expiryYear {
                detailedLabel = Self.createExpiryLabel(expiryMonth: expiryMonth, expiryYear: expiryYear)
            }
        }

        /// - Returns: label with format `MM / YY`
        private static func createExpiryLabel(expiryMonth: Int, expiryYear: Int) -> String {
           return String(format: "%02d", expiryMonth) + " / " + String(expiryYear).suffix(2)
        }
    }
}

extension Input.TextHeader: CellRepresentable {
    var cellType: (UICollectionViewCell & Dequeueable).Type {
        if detailedLabel == nil {
            return Input.Table.LogoTextView.self
        } else {
            return Input.Table.DetailedTextLogoView.self
        }
    }

    func configure(cell: UICollectionViewCell) throws {
        switch cell {
        case let view as Input.Table.LogoTextView: view.configure(with: self)
        case let view as Input.Table.DetailedTextLogoView: view.configure(with: self)
        default: throw errorForIncorrectView(cell)
        }
    }
}
