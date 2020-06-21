#if canImport(UIKit)
import UIKit

/// Could be represented as a table cell
protocol CellRepresentable: class {
    var isEnabled: Bool { get set }
    
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func configure(cell: UICollectionViewCell) throws
}

// If model is `TextInputField` & `DefinesKeyboardStyle`
extension CellRepresentable where Self: DefinesKeyboardStyle {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = view.dequeueReusableCell(Input.Table.TextFieldViewCell.self, for: indexPath)
        return cell
    }

    func configure(cell: UICollectionViewCell) throws {
        guard let textFieldCell = cell as? Input.Table.TextFieldViewCell else { throw errorForIncorrectView(cell) }
        textFieldCell.configure(with: self)
    }
}

extension CellRepresentable where Self: Input.Field.Checkbox {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = view.dequeueReusableCell(Input.Table.CheckboxViewCell.self, for: indexPath)
        return cell
    }

    func configure(cell: UICollectionViewCell) throws {
        guard let checkboxViewCell = cell as? Input.Table.CheckboxViewCell else { throw errorForIncorrectView(cell) }
        checkboxViewCell.configure(with: self)
    }
}

extension CellRepresentable where Self: Input.Field.Label {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = view.dequeueReusableCell(Input.Table.LabelViewCell.self, for: indexPath)
        return cell
    }

    func configure(cell: UICollectionViewCell) throws {
        guard let labelCell = cell as? Input.Table.LabelViewCell else { throw errorForIncorrectView(cell) }
        labelCell.configure(with: self)
    }
}

extension CellRepresentable {
    func errorForIncorrectView(_ view: UIView) -> InternalError {
        return InternalError(description: "Unable to configure unexpected view: %@", objects: view)
    }
}
#endif
