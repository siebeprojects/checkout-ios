#if canImport(UIKit)
import UIKit
import Foundation

class PaymentListTableDataSource: NSObject {
    private let sections: [Section]
    private let translationProvider: TranslationProvider
    
    init(networks: [PaymentNetwork], translation: SharedTranslationProvider) {
        self.translationProvider = translation
        
        let groupedNetworks = GroupingService().group(networks: networks)
        let rows = groupedNetworks.map { Row(networks: $0) }
        sections = [.networks(rows)]
    }
    
    func networks(for indexPath: IndexPath) -> [PaymentNetwork] {
        switch sections[indexPath.section] {
        case .networks(let rows):
            let row = rows[indexPath.row]
            return row.networks
        }
    }
}

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
            let cell = tableView.dequeueReusableCell(PaymentListTableViewCell.self, for: indexPath)
            cell.textLabel?.text = row.label
            cell.imageView?.image = row.logoImage
            return cell
        }
    }
}

// MARK: - Table's model

private enum Section {
    case networks([Row])
}

private class Row {
    let networks: [PaymentNetwork]
    
    var label: String {
        let labels = networks.map { $0.label }
        return labels.joined(separator: ", ")
    }
    
    var logoImage: UIImage? {
        if let network = networks.first, networks.count == 1 {
            // if row has only 1 network
            return network.logo?.image
        } else {
            return nil
        }
    }
    
    init(networks: [PaymentNetwork]) {
        self.networks = networks
    }
}
#endif
