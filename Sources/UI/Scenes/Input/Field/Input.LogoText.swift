import Foundation

extension Input.Field {
    final class LogoText {
        let logoData: Data?
        let label: String

        init(logoData: Data?, label: String) {
            self.logoData = logoData
            self.label = label
        }
    }
}

#if canImport(UIKit)
import UIKit

extension Input.Field.LogoText: CellRepresentable {
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? Input.Table.LogoTextCell else { return }
        cell.configure(with: self)
    }
    
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Input.Table.LogoTextCell.self, for: indexPath)
        return cell
    }
}
#endif
