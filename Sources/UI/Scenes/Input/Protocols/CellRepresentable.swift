#if canImport(UIKit)
import UIKit

/// Could be represented as a table cell
protocol CellRepresentable {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func configure(cell: UICollectionViewCell)
}

// If model is `TextInputField` & `DefinesKeyboardStyle`
extension CellRepresentable where Self: DefinesKeyboardStyle {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = view.dequeueReusableCell(Input.Table.TextFieldViewCell.self, for: indexPath)
        cell.indexPath = indexPath
        return cell
    }

    func configure(cell: UICollectionViewCell) {
        guard let cell = cell as? Input.Table.TextFieldViewCell else { return }
        cell.configure(with: self)
    }
}

extension CellRepresentable where Self == Input.Field.Checkbox {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = view.dequeueReusableCell(Input.Table.CheckboxViewCell.self, for: indexPath)
        cell.indexPath = indexPath
        return cell
    }

    func configure(cell: UICollectionViewCell) {
        guard let cell = cell as? Input.Table.CheckboxViewCell else { return }
        cell.configure(with: self)
    }
}
#endif
