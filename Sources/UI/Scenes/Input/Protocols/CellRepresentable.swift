#if canImport(UIKit)
import UIKit

/// Could be represented as a table cell
protocol CellRepresentable {
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func configure(cell: UITableViewCell)
}

// If model is `TextInputField` & `DefinesKeyboardStyle`
extension CellRepresentable where Self: DefinesKeyboardStyle {
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Input.Table.TextFieldViewCell.self, for: indexPath)
        cell.maxInputLength = maxInputLength
        cell.indexPath = indexPath
        return cell
    }
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? Input.Table.TextFieldViewCell else { return }
        cell.configure(with: self)
    }
}

extension CellRepresentable where Self == Input.Field.Checkbox {
    func dequeueCell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Input.Table.CheckboxViewCell.self, for: indexPath)
        cell.indexPath = indexPath
        return cell
    }
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? Input.Table.CheckboxViewCell else { return }
        cell.configure(with: self)
    }
}
#endif
