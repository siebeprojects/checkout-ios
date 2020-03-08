import UIKit
import Foundation

extension Input.Field {
    final class Button {
        let label: String

        init(label: String) {
            self.label = label
        }
    }
}

extension Input.Field.Button: CellRepresentable {
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? Input.Table.ButtonCell else {
            assertionFailure("Called configure(cell:) from unexpected UITableViewCell")
            return
        }
        cell.configure(with: self)
    }
    
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(Input.Table.ButtonCell.self, for: indexPath)
    }
}
