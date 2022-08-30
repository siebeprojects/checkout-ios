// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import UIKit

/// Cell calls that delegate on some actions
protocol InputCellDelegate: ViewControllerPresenter {
    // swiftlint:disable:previous class_delegate_protocol
    // Lint fails because ViewControllerPresenter is class-bound but linter doesn't know about this.

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
protocol ContainsInputCellDelegate: AnyObject {
    var delegate: InputCellDelegate? { get set }
}
#endif
