// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)

import Foundation
import UIKit

protocol ListTableControllerDelegate: AnyObject {
    func didSelect(paymentNetworks: [UIModel.PaymentNetwork], context: UIModel.PaymentContext)
    func didSelect(registeredAccount: UIModel.RegisteredAccount, context: UIModel.PaymentContext)
    func didSelect(presetAccount: UIModel.PresetAccount, context: UIModel.PaymentContext)
    func didRefreshRequest()

    var downloadProvider: DataDownloadProvider { get }
}

extension List.Table {
    final class Controller: NSObject {
        private let tableView: UITableView

        weak var delegate: ListTableControllerDelegate?

        let dataSource: List.Table.DataSource

        init(tableView: UITableView, session: UIModel.PaymentSession, translationProvider: SharedTranslationProvider, presenter: ViewControllerPresenter?) throws {
            guard let genericLogo = AssetProvider.iconCard else {
                throw InternalError(description: "Unable to load a credit card's generic icon")
            }

            dataSource = .init(
                networks: session.networks,
                accounts: session.registeredAccounts,
                presetAccount: session.presetAccount,
                translation: translationProvider,
                genericLogo: genericLogo,
                context: session.context,
                tintColor: tableView.tintColor,
                presenter: presenter
            )

            self.tableView = tableView
            super.init()

            if session.context.listOperationType == .UPDATE {
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
                tableView.refreshControl = refreshControl
            }
        }

        fileprivate func loadLogo(for indexPath: IndexPath) {
            let models: [ContainsLoadableImage]
            switch dataSource.model(for: indexPath) {
            case .preset(let presetAccount): models = [presetAccount]
            case .account(let account): models = [account]
            case .network(let networks): models = networks
            }

            // Require array to have some not loaded logos, do nothing if everything is loaded
            guard !models.isFullyLoaded else { return }

            delegate?.downloadProvider.downloadImages(for: models, completion: { [weak tableView] in
                DispatchQueue.main.async {
                    tableView?.reloadRows(at: [indexPath], with: .fade)
                }
            })
        }
    }
}

extension List.Table.Controller {
    @objc private func refresh() {
        delegate?.didRefreshRequest()
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
        case .preset(let presetAccount): delegate?.didSelect(presetAccount: presetAccount, context: dataSource.context)
        case .account(let account): delegate?.didSelect(registeredAccount: account, context: dataSource.context)
        case .network(let networks): delegate?.didSelect(paymentNetworks: networks, context: dataSource.context)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataSource.viewForHeaderInSection(section, in: tableView)
    }
}
#endif

// MARK: - Loadable extension

private extension Sequence where Element == ContainsLoadableImage {
    /// Is all elements in array loaded.
    /// - Note: if some elements were loaded but process was finished with error they count as _loaded_ element
    var isFullyLoaded: Bool {
        for element in self {
            if case .notLoaded = element.loadable { return false }
        }

        return true
    }
}
