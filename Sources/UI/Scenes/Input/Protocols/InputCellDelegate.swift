#if canImport(UIKit)
import UIKit

/// Cell calls that delegate on some actions
protocol InputCellDelegate: class {
    func inputCellBecameFirstResponder(at indexPath: IndexPath)
    func inputCellValueDidChange(to newValue: String?, at indexPath: IndexPath)
}

/// Indicates that delegate could be set for that cell
protocol ContainsInputCellDelegate: class {
    var delegate: InputCellDelegate? { get set }
}
#endif
