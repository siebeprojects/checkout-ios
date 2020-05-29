#if canImport(UIKit)
import UIKit

private extension CGFloat {
    /// Set to size of most used cell (`TextFieldViewCell`), if cell would be changed - don't forget to change that value.
    static var estimatedCellHeight: CGFloat { return 87 }
    
    /// Spacing between rows in section
    static var rowLineSpacing: CGFloat { return 8 }
    
    /// Spacing between sections
    static var sectionSpacing: CGFloat { return 16 }
}

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
        weak var inputChangesListener: InputValueChangesListener?
        var scrollViewWillBeginDraggingBlock: ((UIScrollView) -> Void)?
        
        // MARK: - Init
        
        override init() {
            self.validator = Validator(dataSource: dataSource)
            super.init()
            dataSource.inputCellDelegate = self
        }
        
        func setModel(network: Input.Network, header: CellRepresentable) {
            network.submitButton.buttonDidTap = { [weak validator] _ in
                validator?.validateAll(option: .fullCheck)
            }
            
            dataSource.setModel(network: network, header: header)
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
        scrollViewWillBeginDraggingBlock?(scrollView)
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
        inputChangesListener?.valueDidChange(for: inputField)
    }
}
#endif
