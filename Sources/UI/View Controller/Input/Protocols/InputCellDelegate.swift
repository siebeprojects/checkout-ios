#if canImport(UIKit)
import UIKit

protocol InputCellDelegate: class {
    func inputCellBecameFirstResponder(at indexPath: IndexPath)
}

protocol ContainsInputCellDelegate: class {
    var delegate: InputCellDelegate? { get set }
}
#endif
