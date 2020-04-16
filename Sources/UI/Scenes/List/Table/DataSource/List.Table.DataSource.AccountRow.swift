import UIKit

extension List.Table.DataSource {
    class AccountRow {
        let account: RegisteredAccount

        init(account: RegisteredAccount) {
            self.account = account
        }
    }
}

extension List.Table.DataSource.AccountRow {
    var label: String {
        // Example: VISA
        let network = account.networkLabel

        // Example: 41 *** 1111
        var number = account.apiModel.maskedAccount.number ?? String()
        number = String(number.suffix(4)) // 1111

        // Example: VISA •••• 1111
        return network + " •••• " + number
    }

    var image: UIImage? { account.logo?.image }
}

extension List.Table.DataSource.AccountRow: LoadableLogo {
    var logo: Loadable<Data>? {
        get { account.logo }
        set { account.logo = newValue }
    }
}
