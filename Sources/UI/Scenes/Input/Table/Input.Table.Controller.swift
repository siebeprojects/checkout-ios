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
        fileprivate var dataSource: [[CellRepresentable]] {
            didSet { dataSourceDidUpdate(new: dataSource, old: oldValue) }
        }
        
        // Externally set
        
        weak var collectionView: UICollectionView!
        weak var inputChangesListener: InputValueChangesListener?
        var scrollViewWillBeginDraggingBlock: ((UIScrollView) -> Void)?
        
        // MARK: - Init
        
        init(for network: Input.Network, header: CellRepresentable) {
            self.dataSource = Self.arrangeBySections(network: network, header: header)
            super.init()
        }
        
        func configure() {
            registerCells()
            
            collectionView.bounces = true
            
            configure(layout: flowLayout)
            
            collectionView.dataSource = self
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
            layout.estimatedItemSize = CGSize(width: 0, height: .estimatedCellHeight)
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
    func setModel(network: Input.Network, header: CellRepresentable) {
        network.submitButton.buttonDidTap = { [weak self] _ in
            self?.validateFields(option: .fullCheck)
        }
        
        dataSource = Self.arrangeBySections(network: network, header: header)
    }
    
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
    
    func validateFields(option: Input.Field.Validation.Option) {
        // We need to resign a responder to avoid double validation after `textFieldDidEndEditing` event (keyboard will disappear on table reload).
        collectionView.endEditing(true)
        
        for section in dataSource {
            for row in section {
                guard let validatable = row as? Validatable else { continue }
                validatable.validateAndSaveResult(option: option)
            }
        }
        
        collectionView.reloadData()
    }
    
    fileprivate func dataSourceDidUpdate(new: [[CellRepresentable]], old: [[CellRepresentable]]) {
        guard new.count == old.count else {
            collectionView.endEditing(true)
            collectionView.reloadData()
            becomeFirstResponder()
            
            return
        }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        collectionView.performBatchUpdates({
            for (newSectionIndex, newSection) in dataSource.enumerated() {
                guard newSection.count == old[newSectionIndex].count else {
                    collectionView.reloadSections([newSectionIndex])
                    continue
                }
                
                for (newRowIndex, _) in newSection.enumerated() {
                    let currentIndexPath = IndexPath(row: newRowIndex, section: newSectionIndex)
                    
                    guard visibleIndexPaths.contains(currentIndexPath) else {
                        continue
                    }
                    
                    guard let cell = collectionView.cellForItem(at: currentIndexPath) else { continue }
                    let model = dataSource[newSectionIndex][newRowIndex]
                    model.configure(cell: cell)
                }
            }
        })
    }
    
    /// Arrange models by sections
    private static func arrangeBySections(network: Input.Network, header: CellRepresentable) -> [[CellRepresentable]] {
        var sections = [[CellRepresentable]]()
        
        // Header
        sections += [[header]]
        
        // Input Fields
        let inputFields = network.inputFields.filter {
            if $0.isHidden { return false }
            return true
        }
        sections += [inputFields]
        
        // Checkboxes
        var checkboxes = [CellRepresentable]()
        for field in network.separatedCheckboxes where !field.isHidden {
            checkboxes.append(field)
        }
        
        sections += [checkboxes]
        
        // Submit
        sections += [[network.submitButton]]
        
        let dataSource = sections.filter { !$0.isEmpty }
        
        return dataSource
    }
}

// MARK: - UITableViewDataSource

extension Input.Table.Controller: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: .sectionSpacing / 2, left: 0, bottom: .sectionSpacing / 2, right: 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.section][indexPath.row]
        let cell = model.dequeueCell(for: collectionView, indexPath: indexPath)
        cell.tintColor = collectionView.tintColor
        model.configure(cell: cell)
        
        if let cell = cell as? ContainsInputCellDelegate {
            cell.delegate = self
        }
        
        if let cell = cell as? SupportsPrimaryAction {
            let isLastRow = isLastTextField(at: indexPath)
            let action: PrimaryAction = isLastRow ? .done : .next
            cell.setPrimaryAction(to: action)
        }
        
        return cell
    }
    
    private func isLastTextField(at indexPath: IndexPath) -> Bool {
        var lastTextFieldRow: Int?
        
        let rowsInSection = dataSource[indexPath.section]
        for rowIndex in indexPath.row...rowsInSection.count - 1 {
            let element = rowsInSection[rowIndex]
            guard let _ = element as? TextInputField else { continue }
            lastTextFieldRow = rowIndex
        }
        
        if lastTextFieldRow == nil { return true }
        if lastTextFieldRow == indexPath.row { return true }
        
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
}

// MARK: - InputCellDelegate

extension Input.Table.Controller: InputCellDelegate {
    func inputCellPrimaryActionTriggered(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        // If it is a last textfield just dismiss a keyboard
        if isLastTextField(at: indexPath) {
            collectionView.endEditing(false)
            return
        }
        
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        guard let cell = collectionView.cellForItem(at: nextIndexPath) else { return }
        guard cell.canBecomeFirstResponder else { return }
        cell.becomeFirstResponder()
    }
    
    func inputCellDidEndEditing(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        guard let validatableRow = cellRepresentable as? Validatable else { return }
        
        let previousValidationErrorText = validatableRow.validationErrorText
        
        // Validate an input and update a model
        validatableRow.validateAndSaveResult(option: .preCheck)
        
        // Display validation result if cell is visible
        if previousValidationErrorText != validatableRow.validationErrorText, let cell = collectionView.cellForItem(at: indexPath) {
            cellRepresentable.configure(cell: cell)
            cell.layoutIfNeeded()
        }
    }
    
    func inputCellBecameFirstResponder(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        
        if let validatableModel = cellRepresentable as? Validatable, validatableModel.validationErrorText != nil {
            validatableModel.validationErrorText = nil
            
            // Update cell's view if cell is on the screen
            if let textFieldViewCell = collectionView.cellForItem(at: indexPath) as? Input.Table.TextFieldViewCell {
                textFieldViewCell.showValidationResult(for: validatableModel)
                textFieldViewCell.layoutIfNeeded()
            }
        }
    }
    
    func inputCellValueDidChange(to newValue: String?, cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        guard let inputField = cellRepresentable as? InputField else { return }
        
        inputField.value = newValue ?? ""
        inputChangesListener?.valueDidChange(for: inputField)
    }
}
#endif
