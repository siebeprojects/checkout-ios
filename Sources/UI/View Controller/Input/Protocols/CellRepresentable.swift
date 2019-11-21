#if canImport(UIKit)
import UIKit

protocol CellRepresentable {
    func dequeueConfiguredCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}

extension CellRepresentable where Self: DefinesKeyboardStyle {
    func dequeueConfiguredCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TextFieldViewCell.self, for: indexPath)
        cell.configure(with: self)
        return cell
    }
}
#endif
