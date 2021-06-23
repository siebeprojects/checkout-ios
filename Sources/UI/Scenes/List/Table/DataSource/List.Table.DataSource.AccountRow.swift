// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension List.Table.DataSource {
    class AccountRow {
        let account: RegisteredAccount

        init(account: RegisteredAccount) {
            self.account = account
        }
    }
}

// MARK: Computed variables

extension List.Table.DataSource.AccountRow {
    var label: String { account.maskedAccountLabel }
    var image: UIImage? { account.logo?.value }
}

extension List.Table.DataSource.AccountRow: LoadableLogo {
    var logo: Loadable<UIImage>? {
        get { account.logo }
        set { account.logo = newValue }
    }
}
