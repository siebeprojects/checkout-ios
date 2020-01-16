import UIKit

extension List.Table.DataSource {
    /// Model for a single network.
    class SingleNetworkRow {
        let network: PaymentNetwork
        
        init(network: PaymentNetwork) {
            self.network = network
        }
    }
}

extension List.Table.DataSource.SingleNetworkRow {
    var label: String { network.label }
    var image: UIImage? { network.logo?.image }
}

extension List.Table.DataSource.SingleNetworkRow {
    var networks: [PaymentNetwork] { return [network] }
}

extension List.Table.DataSource.SingleNetworkRow: LoadableLogo {
    var logo: Loadable<Data>? {
        get { network.logo }
        set { network.logo = newValue }
    }
}
