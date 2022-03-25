// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input {
    final class TextHeader {
        let logo: UIImage?
        let title: String
        let subtitle: String?
        let subtitleColor: UIColor?
        let trailingButtonImage: UIImage?
        let trailingButtonColor: UIColor?
        var translator: TranslationProvider?
        weak var modalPresenter: ModalPresenter?

        var isEnabled: Bool = true

        init(logo: UIImage?, title: String, subtitle: String? = nil, subtitleColor: UIColor? = nil, trailingButtonImage: UIImage? = nil, trailingButtonColor: UIColor? = nil) {
            self.logo = logo
            self.title = title
            self.subtitle = subtitle
            self.subtitleColor = subtitleColor
            self.trailingButtonImage = trailingButtonImage
            self.trailingButtonColor = trailingButtonColor
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from registeredAccount: UIModel.RegisteredAccount) {
            self.init(
                logo: registeredAccount.logo?.value,
                title: registeredAccount.maskedAccountLabel,
                subtitle: registeredAccount.expirationDate,
                subtitleColor: registeredAccount.isExpired ? CheckoutAppearance.shared.errorColor : CheckoutAppearance.shared.primaryTextColor,
                trailingButtonImage: registeredAccount.isExpired ? AssetProvider.expirationInfo : nil,
                trailingButtonColor: registeredAccount.isExpired ? CheckoutAppearance.shared.errorColor : nil
            )
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from presetAccount: UIModel.PresetAccount) {
            self.init(
                logo: presetAccount.logo?.value,
                title: presetAccount.maskedAccountLabel,
                subtitle: presetAccount.expirationDate,
                subtitleColor: presetAccount.isExpired ? CheckoutAppearance.shared.errorColor : CheckoutAppearance.shared.primaryTextColor,
                trailingButtonImage: presetAccount.isExpired ? AssetProvider.expirationInfo : nil,
                trailingButtonColor: presetAccount.isExpired ? CheckoutAppearance.shared.errorColor : nil
            )
        }
    }
}

extension Input.TextHeader: CellRepresentable {
    var cellType: (UICollectionViewCell & Dequeueable).Type {
        if subtitle == nil {
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
