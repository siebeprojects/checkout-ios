#if canImport(UIKit)

import Foundation
import UIKit

class PaymentListTableController: NSObject {
    var dataSource: [TableGroup]
    weak var tableView: UITableView?

    var loadLogo: ((PaymentNetwork.Logo, @escaping (((Data?) -> Void))) -> Void)?

    init(session: PaymentSession) {
        // FIXME: Use localization provider
        var group = TableGroup(groupName: LocalTranslation.listHeaderNetworks.localizedString)
        group.networks = session.networks
        dataSource = [group]
    }

    fileprivate func loadLogo(for indexPath: IndexPath) {
        let network = self.network(for: indexPath)
        
        // If logo was alread downloaded, do nothing
        if network.logo?.data != nil { return }
        
        guard let logo = network.logo else { return }

        loadLogo?(logo) { [weak self] logoData in
            guard let logoData = logoData else { return }

            self?.dataSource[indexPath.section].networks[indexPath.row].logo?.data = logoData

            DispatchQueue.main.async {
                self?.tableView?.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension PaymentListTableController: UITableViewDataSource {
    fileprivate func network(for indexPath: IndexPath) -> PaymentNetwork {
        return dataSource[indexPath.section].networks[indexPath.row]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].networks.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let network = self.network(for: indexPath)
        let cell = tableView.dequeueReusableCell(PaymentListTableViewCell.self, for: indexPath)
        cell.textLabel?.text = network.label
        cell.imageView?.image = network.logo?.image
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].groupName
    }

    // MARK: -

    struct TableGroup {
        let groupName: String
        var networks = [PaymentNetwork]()

        init(groupName: String) {
            self.groupName = groupName
        }
    }
}

extension PaymentListTableController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            loadLogo(for: indexPath)
        }
    }
}

extension PaymentListTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadLogo(for: indexPath)
    }
}

private extension PaymentNetwork.Logo {
    var image: UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}

#endif
