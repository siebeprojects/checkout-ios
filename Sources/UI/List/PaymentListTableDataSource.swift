#if canImport(UIKit)
import UIKit
import Foundation

class PaymentListTableDataSource: NSObject {
    private let sections: [Section]
    private let translationProvider: TranslationProvider
    
    init(networks: [PaymentNetwork], translation: SharedTranslationProvider) {
        self.translationProvider = translation
        
        // Make an internal model
        let groupedNetworks = GroupingService().group(networks: networks)
        
        var singleRows = [SingleRow]()
        var detailedRows = [DetailedRow]()
        
        for networks in groupedNetworks {
            guard !networks.isEmpty else { continue }
            
            if networks.count == 1, let network = networks.first {
                let row = SingleRow(network: network)
                singleRows.append(row)
            } else {
                let row = DetailedRow(networks: networks)
                detailedRows.append(row)
            }
        }
        
        sections = [.networks(rows: detailedRows + singleRows)]
    }
    
    func networks(for indexPath: IndexPath) -> [PaymentNetwork] {
        switch sections[indexPath.section] {
        case .networks(let rows):
            let row = rows[indexPath.row]
            return row.networks
        }
    }
}

// MARK: - UITableViewDataSource

extension PaymentListTableDataSource: UITableViewDataSource {
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
        case .networks(let rows):
            let row = rows[indexPath.row]
            let cell = row.dequeueConfiguredReusableCell(for: tableView, at: indexPath)
            return cell
        }
    }
}

// MARK: - Table's model

protocol PaymentListTableRow {
    var networks: [PaymentNetwork] { get }
    
    func dequeueConfiguredReusableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

extension PaymentListTableDataSource {
    fileprivate enum Section {
        case networks(rows: [PaymentListTableRow])
    }

    // MARK: Single row
    
    /// Row for a single network
    class SingleRow: PaymentListTableRow {
        let network: PaymentNetwork
        var networks: [PaymentNetwork] { return [network] }
        
        init(network: PaymentNetwork) {
            self.network = network
        }
        
        func dequeueConfiguredReusableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(PaymentListSingleLabelCell.self, for: indexPath)
            
            // Set model
            cell.networkLabel?.text = network.label
            cell.networkLogoView?.image = network.logo?.image
            
            // Set cell position
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            switch indexPath.row {
            case let row where row == 0: cell.cellIndex = .first
            case let row where row == numberOfRows - 1: cell.cellIndex = .last
            default: cell.cellIndex = .middle
            }
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
    
    // MARK: Detailed row
    
    /// Row for a combined network, containing primary and secondary labels
    class DetailedRow: PaymentListTableRow {
        let networks: [PaymentNetwork]

        private var primaryLabel: String {
            guard let firstNetwork = networks.first else {
                return String()
            }
            
            return firstNetwork.translation.translation(forKey: LocalTranslation.creditCard.rawValue)
        }
        
        private var secondaryLabel: String {
            let labels = networks.map { $0.label }
            return labels.joined(separator: " / ")
        }
        
        private var logoImages: [UIImage] {
            return networks.compactMap { $0.logo?.image }
        }
        
        init(networks: [PaymentNetwork]) {
            self.networks = networks
        }
        
        func dequeueConfiguredReusableCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(PaymentListDetailedLabelCell.self, for: indexPath)
            
            // Set model
            cell.primaryLabel?.text = primaryLabel
            cell.secondaryLabel?.text = secondaryLabel
            cell.setImages(logoImages)
            
            // Set cell position
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            switch indexPath.row {
            case let row where row == 0: cell.cellIndex = .first
            case let row where row == numberOfRows - 1: cell.cellIndex = .last
            default: cell.cellIndex = .middle
            }
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
}
#endif
