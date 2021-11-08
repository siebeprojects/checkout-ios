// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import UIKit
import Foundation

extension List.Table {
    final class DataSource: NSObject {
        private let sections: [Section]
        private let translationProvider: TranslationProvider
        let context: UIModel.PaymentContext

        init(networks: [UIModel.PaymentNetwork], accounts: [UIModel.RegisteredAccount]?, presetAccount: UIModel.PresetAccount?, translation: SharedTranslationProvider, genericLogo: UIImage, context: UIModel.PaymentContext) {
            self.translationProvider = translation
            self.context = context

            var sections = [Section]()
            
            if let presetAccount = presetAccount {
                let row = PresetAccountRow(account: presetAccount)
                sections.append(.preset(row: row))
            }

            // Fill accounts
            if let accounts = accounts {
                var rows = [RegisteredAccountRow]()
                for account in accounts {
                    let row = RegisteredAccountRow(account: account)
                    rows.append(row)
                }

                let accountSection = Section.accounts(rows: rows)
                sections.append(accountSection)
            }

            // Fill networks
            let groupedNetworks = GroupingService().group(networks: networks)

            var networkRows = [NetworkRow]()

            for networks in groupedNetworks {
                guard !networks.isEmpty else { continue }

                if networks.count == 1, let network = networks.first {
                    let row = SingleNetworkRow(network: network)
                    networkRows.append(row)
                } else {
                    let row = GroupedNetworkRow(networks: networks, genericLogo: genericLogo)
                    networkRows.append(row)
                }
            }

            let networkSection = Section.networks(rows: networkRows)
            sections.append(networkSection)

            // Don't display empty sections
            self.sections = sections.filter {
                switch $0 {
                case .preset: return true
                case .accounts(let rows): return !rows.isEmpty
                case .networks(let rows): return !rows.isEmpty
                }
            }
        }

        func logo(for indexPath: IndexPath) -> LoadableLogo? {
            switch sections[indexPath.section] {
            case .preset(let presetRow): return presetRow
            case .accounts(let accountRows): return accountRows[indexPath.row]
            case .networks(let networkRows): return networkRows[indexPath.row] as? LoadableLogo
            }
        }

        func model(for indexPath: IndexPath) -> Model {
            switch sections[indexPath.section] {
            case .preset(let presetRow): return .preset(presetRow.account)
            case .accounts(let accountRows): return .account(accountRows[indexPath.row].account)
            case .networks(let networkRows): return .network(networkRows[indexPath.row].networks)
            }
        }
    }
}

extension List.Table.DataSource {
    enum Model {
        case preset(UIModel.PresetAccount)
        case network([UIModel.PaymentNetwork])
        case account(UIModel.RegisteredAccount)
    }
}

// MARK: UITableViewDataSource

extension List.Table.DataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .preset: return 1
        case .accounts(let accounts): return accounts.count
        case .networks(let networks): return networks.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (sections[section], context.listOperationType) {
        case (.preset, .PRESET): return translationProvider.translation(forKey: "networks.preset.title")
        // Preset account couldn't appear in CHARGE and UPDATE flow
        case (.preset, .CHARGE), (.preset, .UPDATE): return ""
        case (.accounts, .CHARGE): return translationProvider.translation(forKey: "accounts.title")
        case (.accounts, .UPDATE): return translationProvider.translation(forKey: "accounts.update.title")
        case (.accounts, .PRESET): return translationProvider.translation(forKey: "accounts.preset.title")
        case (.networks, .CHARGE): return translationProvider.translation(forKey: "networks.title")
        case (.networks, .UPDATE): return translationProvider.translation(forKey: "networks.update.title")
        case (.networks, .PRESET): return translationProvider.translation(forKey: "networks.preset.title")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: DequeuableRow

        switch sections[indexPath.section] {
        case .preset(let presetRow): row = presetRow
        case .accounts(let rows): row = rows[indexPath.row]
        case .networks(let rows): row = rows[indexPath.row]
        }

        return row.dequeueConfiguredReusableCell(for: tableView, at: indexPath)
    }
}

// MARK: - Table's model

extension List.Table.DataSource {
    fileprivate enum Section {
        case preset(row: PresetAccountRow)
        case accounts(rows: [RegisteredAccountRow])
        case networks(rows: [NetworkRow])
    }
}

// MARK: - Protocols

private protocol DequeuableRow {
    func dequeueConfiguredReusableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

private protocol NetworkRow: DequeuableRow {
    var networks: [UIModel.PaymentNetwork] { get }
}

private protocol SingleLabelRow: DequeuableRow {
    var label: String { get }
    var image: UIImage? { get }
    var borderColor: UIColor { get }
}

extension SingleLabelRow {
    func dequeueConfiguredReusableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(List.Table.SingleLabelCell.self, for: indexPath)

        // Set model
        cell.networkLabel?.text = label
        cell.networkLogoView?.image = image
        cell.borderColor = self.borderColor

        // Set cell position
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)

        if numberOfRows == 1 {
            cell.cellIndex = .singleCell
        } else {
            switch indexPath.row {
            case let row where row == 0: cell.cellIndex = .first
            case let row where row == numberOfRows - 1: cell.cellIndex = .last
            default: cell.cellIndex = .middle
            }
        }

        return cell
    }
}

// MARK: Extensions to model

extension List.Table.DataSource.PresetAccountRow: SingleLabelRow {
    var borderColor: UIColor { return .tablePresetBordersColor }
}
extension List.Table.DataSource.RegisteredAccountRow: SingleLabelRow {
    var borderColor: UIColor { return .themedTableBorder }
}
extension List.Table.DataSource.SingleNetworkRow: SingleLabelRow, NetworkRow {
    var borderColor: UIColor { return .themedTableBorder }
}
extension List.Table.DataSource.GroupedNetworkRow: NetworkRow {}

#endif
