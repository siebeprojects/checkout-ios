#if canImport(UIKit)

import Foundation
import UIKit

protocol ListTableControllerDelegate: class {
    func didSelect(paymentNetworks: [PaymentNetwork])
    func didSelect(registeredAccount: RegisteredAccount)
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

extension List.Table {
    final class Controller: NSObject {
        weak var tableView: UITableView?
        weak var delegate: ListTableControllerDelegate?

        let dataSource: List.Table.DataSource
        
        init(session: PaymentSession, translationProvider: SharedTranslationProvider) throws {
            guard let genericLogo = AssetProvider.iconCard else {
                throw InternalError(description: "Unable to load a credit card's generic icon")
            }
            
            dataSource = .init(networks: session.networks, accounts: session.registeredAccounts, translation: translationProvider, genericLogo: genericLogo)
        }
        
        func viewDidLayoutSubviews() {
            guard let tableView = self.tableView else { return }
            for cell in tableView.visibleCells {
                guard let paymentCell = cell as? List.Table.BorderedCell else { continue }
                paymentCell.viewDidLayoutSubviews()
            }
        }

        fileprivate func loadLogo(for indexPath: IndexPath) {
            guard let model = dataSource.logo(for: indexPath) else { return }
            
            /// If logo was already downloaded
            guard case let .some(.notLoaded(url)) = model.logo else { return }
            
            delegate?.load(from: url) { [weak self] result in
                model.logo = .loaded(result)

                // Don't reload rows if multiple networks (we don't show logos for now for them)
                // TODO: Potential multiple updates for a single cell
                DispatchQueue.main.async {
                    self?.tableView?.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}


extension List.Table.Controller: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            loadLogo(for: indexPath)
        }
    }
}

extension List.Table.Controller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadLogo(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource.model(for: indexPath) {
        case .account(let account): delegate?.didSelect(registeredAccount: account)
        case .network(let networks): delegate?.didSelect(paymentNetworks: networks)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = List.Table.SectionHeader(frame: .zero)
        view.textLabel?.text = tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: section)
        return view
    }
}
#endif
