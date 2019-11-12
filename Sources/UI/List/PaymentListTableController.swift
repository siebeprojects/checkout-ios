#if canImport(UIKit)

import Foundation
import UIKit

class PaymentListTableController: NSObject {
    private let sections: [Section]
    weak var tableView: UITableView?

    let translationProvider: TranslationProvider
    
    var loadLogo: ((PaymentNetwork.Logo, @escaping (((Data?) -> Void))) -> Void)?

    init(networks: [PaymentNetwork], translationProvider: TranslationProvider) {
        sections = [.networks(networks)]
        self.translationProvider = translationProvider
    }

    fileprivate func loadLogo(for indexPath: IndexPath) {
        let optionalLogo: PaymentNetwork.Logo?
        
        switch sections[indexPath.section] {
        case .networks(let networks):
            optionalLogo = networks[indexPath.row].logo
        }

        // There is no logo for that cell
        guard let logo = optionalLogo else { return }
        
        /// If logo was already downloaded
        guard logo.data == nil else { return }

        loadLogo?(logo) { [weak self] logoData in
            guard let logoData = logoData else { return }
            logo.data = logoData

            DispatchQueue.main.async {
                self?.tableView?.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}

extension PaymentListTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .networks(let networks): return networks.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .networks: return translationProvider.translation(forKey: LocalTranslation.listHeaderNetworks.rawValue)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .networks(let networks):
            let network = networks[indexPath.row]
            let cell = tableView.dequeueReusableCell(PaymentListTableViewCell.self, for: indexPath)
            cell.textLabel?.text = network.label
            cell.imageView?.image = network.logo?.image
            return cell
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

private enum Section {
    case networks([PaymentNetwork])
}

#endif
