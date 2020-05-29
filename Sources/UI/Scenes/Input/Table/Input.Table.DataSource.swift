import UIKit

extension Input.Table {
    class DataSource: NSObject {
        weak var inputCellDelegate: InputCellDelegate?
        fileprivate(set) var model: [[CellRepresentable]] = .init()
        
        func setModel(network: Input.Network, header: CellRepresentable) {
            model = Self.arrangeBySections(network: network, header: header)
        }
        
        func isLastTextField(at indexPath: IndexPath) -> Bool {
            var lastTextFieldRow: Int?
            
            let rowsInSection = model[indexPath.section]
            for rowIndex in indexPath.row...rowsInSection.count - 1 {
                let element = rowsInSection[rowIndex]
                guard let _ = element as? TextInputField else { continue }
                lastTextFieldRow = rowIndex
            }
            
            if lastTextFieldRow == nil { return true }
            if lastTextFieldRow == indexPath.row { return true }
            
            return false
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
}

// MARK: - UICollectionViewDataSource

extension Input.Table.DataSource: UICollectionViewDataSource {    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = model[indexPath.section][indexPath.row]
        let cell = cellModel.dequeueCell(for: collectionView, indexPath: indexPath)
        cell.tintColor = collectionView.tintColor

        do {
            try cellModel.configure(cell: cell)
        } catch {
            log(error)
        }
        
        if let cell = cell as? ContainsInputCellDelegate {
            cell.delegate = inputCellDelegate
        }
        
        if let cell = cell as? SupportsPrimaryAction {
            let isLastRow = isLastTextField(at: indexPath)
            let action: PrimaryAction = isLastRow ? .done : .next
            cell.setPrimaryAction(to: action)
        }
        
        return cell
    }
}
