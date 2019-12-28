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
    
    func viewDidLayoutSubviews() {
        guard let tableView = self.tableView else { return }
        for cell in tableView.visibleCells {
            guard let paymentCell = cell as? PaymentListTableViewCell else { continue }
            paymentCell.viewDidLayoutSubviews()
        }
    }

    fileprivate func loadLogo(for indexPath: IndexPath) {
        let networks = dataSource.networks(for: indexPath)
        
        for network in networks {
            /// If logo was already downloaded
            guard case let .some(.notLoaded(url)) = network.logo else { continue }
            
            delegate?.load(from: url) { [weak self] result in
                network.logo = .loaded(result)

                // Don't reload rows if multiple networks (we don't show logos for now for them)
                guard networks.count == 1 else { return }
                DispatchQueue.main.async {
                    self?.tableView?.reloadRows(at: [indexPath], with: .fade)
                }
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
