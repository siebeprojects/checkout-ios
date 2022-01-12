// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input {
    final class TextHeader {
        let logo: UIImage?
        let label: String
        let detailedLabel: String?
        let trailingButtonImage: UIImage?
        var isEnabled: Bool = true
        var translator: TranslationProvider?
        weak var modalPresenter: ModalPresenter?

        init(logo: UIImage?, label: String, detailedLabel: String? = nil, trailingButtonImage: UIImage? = nil) {
            self.logo = logo
            self.label = label
            self.detailedLabel = detailedLabel
            self.trailingButtonImage = trailingButtonImage
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from registeredAccount: UIModel.RegisteredAccount) {
            self.init(
                logo: registeredAccount.logo?.value,
                label: registeredAccount.maskedAccountLabel,
                detailedLabel: registeredAccount.expirationDate,
                trailingButtonImage: registeredAccount.isExpired ? AssetProvider.expirationInfo : nil
            )
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from presetAccount: UIModel.PresetAccount) {
            self.init(
                logo: presetAccount.logo?.value,
                label: presetAccount.maskedAccountLabel,
                detailedLabel: presetAccount.expirationDate,
                trailingButtonImage: presetAccount.isExpired ? AssetProvider.expirationInfo : nil
            )
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
