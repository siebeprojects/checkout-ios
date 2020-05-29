import UIKit
import Foundation

extension Input.Field {
    final class Button {
        let label: String

        var buttonDidTap: ((Button) -> Void)?

        init(label: String) {
            self.label = label
        }
    }
}

extension Input.Field.Button: CellRepresentable {
    func configure(cell: UICollectionViewCell) throws {
        guard let buttonCell = cell as? Input.Table.ButtonCell else {
            throw errorForIncorrectView(cell)
        }
        buttonCell.configure(with: self)
    }

    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return view.dequeueReusableCell(Input.Table.ButtonCell.self, for: indexPath)
    }
}
