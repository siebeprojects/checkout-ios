// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table.DataSource {
    class RegisteredAccountRow {
        let account: UIModel.RegisteredAccount
        weak var presenter: ViewControllerPresenter?

        init(account: UIModel.RegisteredAccount, presenter: ViewControllerPresenter?) {
            self.account = account
            self.presenter = presenter
        }
    }
}

// MARK: Computed variables

extension List.Table.DataSource.RegisteredAccountRow {
    var primaryLabel: String { account.maskedAccountLabel }
    var image: UIImage? { account.logo?.value }
}

extension List.Table.DataSource.RegisteredAccountRow: LoadableLogo {
    var logo: Loadable<UIImage>? {
        get { account.logo }
        set { account.logo = newValue }
    }
}
