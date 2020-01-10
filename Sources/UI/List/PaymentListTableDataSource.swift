#if canImport(UIKit)
import UIKit
import Foundation

class PaymentListTableDataSource: NSObject {
    private let sections: [Section]
    private let translationProvider: TranslationProvider
    
    init(networks: [PaymentNetwork], translation: SharedTranslationProvider, genericLogo: UIImage) {
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
                let row = DetailedRow(networks: networks, genericLogo: genericLogo)
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

// MARK: UITableViewDataSource

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
}

// MARK: - Single row

extension PaymentListTableDataSource {
    /// Row for a single network
    class SingleRow {
        let network: PaymentNetwork
        var networks: [PaymentNetwork] { return [network] }

        init(network: PaymentNetwork) {
            self.network = network
        }
    }
}

extension PaymentListTableDataSource.SingleRow: PaymentListTableRow {
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

// MARK: - Detailed row

extension PaymentListTableDataSource {
    /// Row for a combined network, containing primary and secondary labels
    class DetailedRow {
        let networks: [PaymentNetwork]

        private let genericLogo: UIImage
        private var maxDisplayableLogos = 2
        
        init(networks: [PaymentNetwork], genericLogo: UIImage) {
            self.networks = networks
            self.genericLogo = genericLogo
        }
    }
}

// MARK: Computed variables

extension PaymentListTableDataSource.DetailedRow {
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
        if networks.count > maxDisplayableLogos {
            return [genericLogo]
        }
        
        var allLogos = [UIImage]()
        
        for network in networks {
            switch network.logo {
            // Network doesn't have a logo, we don't want to show "some" logos that may confuse an user, show a generic icon
            case .none: return [genericLogo]
                
            // Logo is being downloadedd, just show an empty space to avoid flickering
            case .notLoaded: return .init()
                
            case .loaded(let loadResult):
                switch loadResult {
                // Logo was failed to download, show a generic logo, don't show "some" logos
                case .failure: return [genericLogo]
                    
                // Checks were passed, add logo to a stack
                case .success(let imageData):
                    guard let image = UIImage(data: imageData) else {
                        return [genericLogo]
                    }
                    
                    allLogos.append(image)
                }
            }
        }
        
        return allLogos
    }
}

// MARK: PaymentListTableRow

extension PaymentListTableDataSource.DetailedRow: PaymentListTableRow {
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
#endif
