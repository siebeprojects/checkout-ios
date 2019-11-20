#if canImport(UIKit)

import Foundation
import UIKit

protocol PaymentListTableControllerDelegate: class {
    func didSelect(paymentNetwork: PaymentNetwork)
    func load(logo: PaymentNetwork.Logo, completion: @escaping (Data?) -> Void)
}

class PaymentListTableController: NSObject {
    private let sections: [Section]
    weak var tableView: UITableView?

    let translationProvider: TranslationProvider
    
    weak var delegate: PaymentListTableControllerDelegate?

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

        delegate?.load(logo: logo) { [weak self] logoData in
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .networks(let networks):
            delegate?.didSelect(paymentNetwork: networks[indexPath.row])
        }
    }
}

private enum Section {
    case networks([PaymentNetwork])
}

#endif
