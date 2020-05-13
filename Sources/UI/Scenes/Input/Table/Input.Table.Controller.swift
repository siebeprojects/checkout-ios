#if canImport(UIKit)
import UIKit

extension Input.Table {
    /// Acts as a datasource and delegate for input table views and responds on delegate events from a table and cells.
    /// - Note: We use custom section approach (sections are presented as rows `SectionHeaderCell`) because we have to use `.plain` table type to get correct `tableView.contentSize` calculations and plain table type has floating sections that we don't want, so we switched to sections as rows.
    /// - See also: `DataSourceElement`
    class Controller: NSObject {
        let flowLayout = FlowLayout()
        private var dataSource: [[CellRepresentable]]

        // MARK: Externally set
        var network: Input.Network {
            didSet {
                networkDidUpdate(new: network, old: oldValue)
            }
        }

        weak var collectionView: UICollectionView!
        weak var inputChangesListener: InputValueChangesListener?
        var scrollViewWillBeginDraggingBlock: ((UIScrollView) -> Void)?

        var headerModel: CollectionViewRepresentable?

        init(for network: Input.Network) {
            self.network = network
            self.dataSource = Self.arrangeBySections(network: network)

            super.init()
        }
        
        func configure() {
            network.submitButton.buttonDidTap = { [weak self] _ in
                self?.validateFields(option: .fullCheck)
            }
            
            registerCells()

            collectionView.bounces = true

            configure(layout: flowLayout)
            
            collectionView.dataSource = self
            collectionView.delegate = self
            
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .always
            }
        }
        
        func configureHeader() {
            guard let model = self.headerModel else { return }
            guard let visible = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: [0,0]) as? UICollectionReusableView & DequeueableCell else { return }
            
            try? model.configure(view: visible)
        }
        
        private func configure(layout: UICollectionViewFlowLayout) {
            if #available(iOS 11.0, *) {
                layout.sectionInsetReference = .fromContentInset
            }
            
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//            layout.minimumInteritemSpacing = 10
//            layout.minimumLineSpacing = 10
//            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

        private func registerCells() {
            collectionView.register(TextFieldViewCell.self)
            collectionView.register(CheckboxViewCell.self)
            collectionView.register(ButtonCell.self)
            
            // Headers
            collectionView.register(SectionHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(DetailedTextLogoView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(LogoTextView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(ImagesView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        }

        @discardableResult
        func becomeFirstResponder() -> Bool {
            for cell in collectionView.visibleCells {
                guard cell.canBecomeFirstResponder else { continue }

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

        private func networkDidUpdate(new: Input.Network, old: Input.Network) {
            new.submitButton.buttonDidTap = { [weak self] _ in
                self?.validateFields(option: .fullCheck)
            }

            guard !network.inputFields.isEmpty else {
                collectionView.reloadData()
                return
            }

            let oldDataSource = dataSource
            self.dataSource = Self.arrangeBySections(network: new)

            guard dataSource.count == oldDataSource.count else {
                collectionView.endEditing(true)
                collectionView.reloadData()
                becomeFirstResponder()

                return
            }
            
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            collectionView.performBatchUpdates({
                for (newSectionIndex, newSection) in dataSource.enumerated() {
                    guard newSection.count == oldDataSource[newSectionIndex].count else {
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
        private static func arrangeBySections(network: Input.Network) -> [[CellRepresentable]] {
            var sections = [[CellRepresentable]]()

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
}

// MARK: - UITableViewDataSource

extension Input.Table.Controller: UICollectionViewDataSource {
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            guard let headerModel = self.headerModel else {
                fallthrough
            }
            
            let sectionView = headerModel.dequeueReusableSupplementaryView(for: collectionView, ofKind: kind, for: indexPath)
            do {
                try headerModel.configure(view: sectionView)
            } catch {
                fallthrough
            }
            
            return sectionView
        default:
            return collectionView.dequeueReusableSupplementaryView(Input.Table.SectionHeaderCell.self, ofKind: kind, for: indexPath)
        }
    }
    
    private func isLastTextField(at indexPath: IndexPath) -> Bool {
        return true
        // FIXME
//        var lastTextFieldRow: Int?
//
//        for row in indexPath.row...dataSource.count - 1 {
//            let element = dataSource[row]
//            guard case let .row(rowModel) = element, let _ = rowModel as? TextInputField else { continue }
//            lastTextFieldRow = row
//        }
//
//        if lastTextFieldRow == nil { return true }
//        if lastTextFieldRow == indexPath.row { return true }
//
//        return false
    }
}

extension Input.Table.Controller: UICollectionViewDelegate {
    // FIXME
//    func tableView(_ collectionView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch dataSource[indexPath.row] {
//        case .separator: return Input.Table.SectionHeaderCell.Constant.height
//        case .row(let cell): return cell.estimatedHeightForRow
//        }
//    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewWillBeginDraggingBlock?(scrollView)
    }
}

extension Input.Table.Controller: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Get the view for the first header
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        // Use this view to calculate the optimal size based on the collection view's width
        let headerFrameSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        return headerView.systemLayoutSizeFitting(headerFrameSize)
    }
}

// MARK: - InputCellDelegate

extension Input.Table.Controller: InputCellDelegate {
    func inputCellPrimaryActionTriggered(at indexPath: IndexPath) {
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

    func inputCellDidEndEditing(at indexPath: IndexPath) {
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        guard let validatableRow = cellRepresentable as? Validatable else { return }

        // Validate an input and update a model
        validatableRow.validateAndSaveResult(option: .preCheck)
        
        // Display validation result if cell is visible
        if let cell = collectionView.cellForItem(at: indexPath) {
            collectionView.performBatchUpdates({
                cellRepresentable.configure(cell: cell)
            }, completion: nil)
        }
    }

    func inputCellBecameFirstResponder(at indexPath: IndexPath) {
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]

        if let validatableModel = cellRepresentable as? Validatable, validatableModel.validationErrorText != nil {
            validatableModel.validationErrorText = nil

            collectionView.performBatchUpdates({
                switch collectionView.cellForItem(at: indexPath) {
                case let textFieldViewCell as Input.Table.TextFieldViewCell:
                    textFieldViewCell.showValidationResult(for: validatableModel)
                default: break
                }
            }) { _ in }
        }

        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
    }

    func inputCellValueDidChange(to newValue: String?, at indexPath: IndexPath) {
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        guard let inputField = cellRepresentable as? InputField else { return }

        inputField.value = newValue ?? ""
        inputChangesListener?.valueDidChange(for: inputField)
    }
}
#endif
