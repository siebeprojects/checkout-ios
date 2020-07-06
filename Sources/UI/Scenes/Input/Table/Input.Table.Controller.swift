#if canImport(UIKit)
import UIKit

// MARK: Constants

private extension CGFloat {
    /// Set to size of most used cell (`TextFieldViewCell`), if cell would be changed - don't forget to change that value.
    static var estimatedCellHeight: CGFloat { return 87 }

    /// Spacing between rows in section
    static var rowLineSpacing: CGFloat { return 8 }

    /// Spacing between sections
    static var sectionSpacing: CGFloat { return 16 }
}

// MARK: - InputTableControllerDelegate

protocol InputTableControllerDelegate: class {
    func submitPayment()
    func valueDidChange(for field: InputField)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
}

// MARK: - Input.Table.Controller

extension Input.Table {
    class Controller: NSObject {
        let flowLayout = FlowLayout()
        let dataSource = DataSource()
        let validator: Validator

        // Externally set

        weak var collectionView: UICollectionView! {
            didSet {
                validator.collectionView = collectionView
            }
        }
        weak var delegate: InputTableControllerDelegate?

        override init() {
            self.validator = Validator(dataSource: dataSource)
            super.init()
            dataSource.inputCellDelegate = self
        }

        func setModel(network: Input.Network, header: CellRepresentable) {
            network.uiModel.submitButton.buttonDidTap = { [weak self] _ in
                if self?.validator.validateAll(option: .fullCheck) == true {
                    self?.delegate?.submitPayment()
                }
            }

            let oldModel = dataSource.model
            dataSource.setModel(network: network, header: header)

            if collectionView != nil {
                reloadCollectionView(with: dataSource.model, oldModel: oldModel)
            }
        }

        func configure() {
            registerCells()

            collectionView.bounces = true

            configure(layout: flowLayout)

            collectionView.dataSource = dataSource
            collectionView.delegate = self

            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
            }
            if #available(iOS 13.0, *) {
                collectionView.automaticallyAdjustsScrollIndicatorInsets = false
            }
        }

        private func reloadCollectionView(with newModel: [[CellRepresentable]], oldModel: [[CellRepresentable]]) {
            // Ensure old model is not empty, if it is just reload
            guard !oldModel.isEmpty else {
                collectionView.reloadData()
                return
            }

            // I disable animation for iOS 12 and lower because it cause animation bugs (it's related to dynamic cell size calculations) and animation for that block is not important.
            // Radar: http://www.openradar.me/23728611
            // Article describing the same situation: https://jakubturek.com/uicollectionview-self-sizing-cells-animation/
            if #available(iOS 13, *) {
                // Everything is okay, nothing to disable
            } else {
                UIView.setAnimationsEnabled(false)
            }

            collectionView.performBatchUpdates({
                let diff = DataSource.Diff(old: oldModel, new: newModel)
                diff.applyChanges(for: collectionView)
            }, completion: { _ in
                if #available(iOS 13, *) {
                    // Animations weren't disabled, skip it
                } else {
                    UIView.setAnimationsEnabled(true)
                }
            })
        }

        private func configure(layout: UICollectionViewFlowLayout) {
            if #available(iOS 11.0, *) {
                layout.sectionInsetReference = .fromContentInset
            }

            layout.minimumLineSpacing = .rowLineSpacing
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        private func registerCells() {
            // Input field cells
            collectionView.register(TextFieldViewCell.self)
            collectionView.register(CheckboxViewCell.self)
            collectionView.register(ButtonCell.self)
            collectionView.register(LabelViewCell.self)

            // Header cells
            collectionView.register(DetailedTextLogoView.self)
            collectionView.register(LogoTextView.self)
            collectionView.register(ImagesView.self)
        }
    }
}

extension Input.Table.Controller {
    @discardableResult
    func becomeFirstResponder() -> Bool {
        var indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems
        indexPathsForVisibleItems.sort { $0.compare($1) == .orderedAscending }

        for indexPath in indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: indexPath), cell.canBecomeFirstResponder else {
                continue
            }

            cell.becomeFirstResponder()
            return true
        }

        return false
    }
}

extension Input.Table.Controller: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }
}

extension Input.Table.Controller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: .sectionSpacing / 2, left: 0, bottom: .sectionSpacing / 2, right: 0)
    }
}

// MARK: - InputCellDelegate

extension Input.Table.Controller: InputCellDelegate {
    func inputCellPrimaryActionTriggered(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }

        // If it is a last textfield just dismiss a keyboard
        if dataSource.isLastTextField(at: indexPath) {
            collectionView.endEditing(false)
            return
        }

        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        guard let cell = collectionView.cellForItem(at: nextIndexPath) else { return }
        guard cell.canBecomeFirstResponder else { return }
        cell.becomeFirstResponder()
    }

    func inputCellDidEndEditing(cell: UICollectionViewCell) {
        validator.validate(cell: cell)
    }

    func inputCellBecameFirstResponder(cell: UICollectionViewCell) {
        validator.removeValidationError(for: cell)
    }

    func inputCellValueDidChange(to newValue: String?, cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }

        let cellRepresentable = dataSource.model[indexPath.section][indexPath.row]
        guard let inputField = cellRepresentable as? InputField else { return }

        inputField.value = newValue ?? ""
        delegate?.valueDidChange(for: inputField)
    }
}
#endif
