#if canImport(UIKit)

import Foundation
import UIKit

protocol PaymentListTableControllerDelegate: class {
    func didSelect(paymentNetworks: [PaymentNetwork])
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

class PaymentListTableController: NSObject {
    weak var tableView: UITableView?
    weak var delegate: PaymentListTableControllerDelegate?

    let dataSource: PaymentListTableDataSource
    
    init(networks: [PaymentNetwork], translationProvider: SharedTranslationProvider) {
        dataSource = .init(networks: networks, translation: translationProvider)
    }

    fileprivate func loadLogo(for indexPath: IndexPath) {
        let networks = dataSource.networks(for: indexPath)
        
        // Don't load logo for multiple networks for now
        guard let network = networks.first, networks.count == 1 else { return }

        /// If logo was already downloaded
        guard case let .some(.notLoaded(url)) = network.logo else { return }

        delegate?.load(from: url) { [weak self] result in
            network.logo = .loaded(result)

            DispatchQueue.main.async {
                self?.tableView?.reloadRows(at: [indexPath], with: .fade)
            }
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
        let selectedNetworks = dataSource.networks(for: indexPath)
        delegate?.didSelect(paymentNetworks: selectedNetworks)
    }
}
#endif
