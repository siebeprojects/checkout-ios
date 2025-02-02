// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table.DataSource {
    class PresetAccountRow {
        let account: UIModel.PresetAccount
        let tintColor: UIColor
        weak var presenter: ViewControllerPresenter?

        init(account: UIModel.PresetAccount, tintColor: UIColor, presenter: ViewControllerPresenter?) {
            self.account = account
            self.tintColor = tintColor
            self.presenter = presenter
        }
    }
}

// MARK: Computed variables

extension List.Table.DataSource.PresetAccountRow {
    var primaryLabel: String { account.maskedAccountLabel }
    var image: UIImage? { account.logo?.value }
}

extension List.Table.DataSource.PresetAccountRow: LoadableLogo {
    var logo: Loadable<UIImage>? {
        get { account.logo }
        set { account.logo = newValue }
    }
}
