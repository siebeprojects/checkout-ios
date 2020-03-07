import UIKit
import Foundation

extension Input.Field {
    final class Header {
        let logoData: Data?
        let label: String
        var detailedLabel: String?

        init(logoData: Data?, label: String) {
            self.logoData = logoData
            self.label = label
        }
    }
}

extension Input.Field.Header: CellRepresentable {
    func configure(cell: UITableViewCell) {
        switch cell {
        case let cell as Input.Table.LogoTextCell: cell.configure(with: self)
        case let cell as Input.Table.DetailedTextLogoCell: cell.configure(with: self)
        default:
            assertionFailure("Called configure(cell:) from unexpected UITableViewCell")
            return
        }
    }
    
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if detailedLabel != nil {
            return tableView.dequeueReusableCell(Input.Table.DetailedTextLogoCell.self, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(Input.Table.LogoTextCell.self, for: indexPath)
        }
    }
}
