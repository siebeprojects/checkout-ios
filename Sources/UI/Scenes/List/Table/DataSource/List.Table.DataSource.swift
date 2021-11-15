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
                let presetSection = Section(rows: .preset(row), additionalHeaderText: presetAccount.warningText)
                sections.append(presetSection)
            }

            // Fill accounts
            if let accounts = accounts {
                var rows = [RegisteredAccountRow]()
                for account in accounts {
                    let row = RegisteredAccountRow(account: account)
                    rows.append(row)
                }

                let accountSection = Section(rows: .accounts(rows), additionalHeaderText: nil)
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

            let networkSection = Section(rows: .networks(networkRows), additionalHeaderText: nil)
            sections.append(networkSection)

            // Don't display empty sections
            self.sections = sections.filter {
                switch $0.rows {
                case .preset: return true
                case .accounts(let rows): return !rows.isEmpty
                case .networks(let rows): return !rows.isEmpty
                }
            }
        }

        func logo(for indexPath: IndexPath) -> LoadableLogo? {
            switch sections[indexPath.section].rows {
            case .preset(let presetRow): return presetRow
            case .accounts(let accountRows): return accountRows[indexPath.row]
            case .networks(let networkRows): return networkRows[indexPath.row] as? LoadableLogo
            }
        }

        func model(for indexPath: IndexPath) -> Model {
            switch sections[indexPath.section].rows {
            case .preset(let presetRow): return .preset(presetRow.account)
            case .accounts(let accountRows): return .account(accountRows[indexPath.row].account)
            case .networks(let networkRows): return .network(networkRows[indexPath.row].networks)
            }
        }

        func viewForHeaderInSection(_ section: Int, in tableView: UITableView) -> UIView {
            let section = sections[section]
            let labelTranslationKey: String

            switch (section.rows, context.listOperationType) {
            case (.preset, .PRESET): labelTranslationKey = "networks.preset.title"
            case (.preset, .CHARGE), (.preset, .UPDATE):
                // Preset account couldn't appear in CHARGE and UPDATE flow
                labelTranslationKey = ""
            case (.accounts, .CHARGE): labelTranslationKey = "accounts.title"
            case (.accounts, .UPDATE): labelTranslationKey = "accounts.update.title"
            case (.accounts, .PRESET): labelTranslationKey = "accounts.title"
            case (.networks, .CHARGE): labelTranslationKey = "networks.title"
            case (.networks, .UPDATE): labelTranslationKey = "networks.update.title"
            case (.networks, .PRESET): labelTranslationKey = "networks.title"
            }

            // Create a view
            if let additionalHeaderText = section.additionalHeaderText {
                let view = tableView.dequeueReusableHeaderFooterView(List.Table.DetailedHeaderView.self)
                view.primaryLabel.text = translationProvider.translation(forKey: labelTranslationKey)
                view.secondaryLabel.text = additionalHeaderText
                return view
            } else {
                let view = List.Table.SectionHeader(frame: .zero)
                view.textLabel?.text = translationProvider.translation(forKey: labelTranslationKey)
                return view
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
        switch sections[section].rows {
        case .preset: return 1
        case .accounts(let accounts): return accounts.count
        case .networks(let networks): return networks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row: DequeuableRow

        switch sections[indexPath.section].rows {
        case .preset(let presetRow): row = presetRow
        case .accounts(let rows): row = rows[indexPath.row]
        case .networks(let rows): row = rows[indexPath.row]
        }

        return row.dequeueConfiguredReusableCell(for: tableView, at: indexPath)
    }
}

// MARK: - Table's model

extension List.Table.DataSource {
    fileprivate struct Section {
        let rows: Rows
        let additionalHeaderText: String?
    }

    fileprivate enum Rows {
        case preset(PresetAccountRow)
        case accounts([RegisteredAccountRow])
        case networks([NetworkRow])
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
