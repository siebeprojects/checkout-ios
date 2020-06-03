#if canImport(UIKit)
import UIKit

/// Cell calls that delegate on some actions
protocol InputCellDelegate: class {
    func inputCellBecameFirstResponder(cell: UICollectionViewCell)
    func inputCellValueDidChange(to newValue: String?, cell: UICollectionViewCell)
    func inputCellDidEndEditing(cell: UICollectionViewCell)

    /// Action button was tapped (e.g. `Next` or `Done`)
    func inputCellPrimaryActionTriggered(cell: UICollectionViewCell)
}

extension InputCellDelegate {
    func inputCellBecameFirstResponder(cell: UICollectionViewCell) {}
}

/// Indicates that delegate could be set for that cell
protocol ContainsInputCellDelegate: class {
    var delegate: InputCellDelegate? { get set }
}
#endif
