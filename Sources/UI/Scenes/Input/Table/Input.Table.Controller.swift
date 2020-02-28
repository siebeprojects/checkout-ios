#if canImport(UIKit)
import UIKit

extension Input.Table {
    /// Acts as a datasource for input table views and responds on delegate events from a table and cells.
    class Controller: NSObject {
        var network: Input.Network {
            didSet {
                networkDidUpdate(new: network, old: oldValue)
            }
        }
        
        unowned let tableView: UITableView
        private var dataSource: [[CellRepresentable]]
        weak var inputChangesListener: InputValueChangesListener?
        
        init(for network: Input.Network, tableView: UITableView) {
            self.network = network
            self.tableView = tableView
            
            dataSource = Self.arrangeBySections(network: network)
            super.init()
        }
        
        func registerCells() {
            tableView.register(TextFieldViewCell.self)
            tableView.register(CheckboxViewCell.self)
            tableView.register(LogoTextCell.self)
        }
        
        func validateFields(option: Input.Field.Validation.Option) {
            // We need to resign a responder to avoid double validation after `textFieldDidEndEditing` event (keyboard will disappear on table reload).
            tableView.endEditing(true)
            
            for cell in dataSource.flatMap({ $0 }) {
                guard let validatable = cell as? Validatable else { continue }
                validatable.validateAndSaveResult(option: option)
            }
            
            tableView.reloadData()
        }
        
        private func networkDidUpdate(new: Input.Network, old: Input.Network) {
            guard !network.inputFields.isEmpty else {
                tableView.reloadData()
                return
            }
            
            let oldDataSource = dataSource
            dataSource = Self.arrangeBySections(network: new)
            
            for (sectionNumber, newSectionFields) in dataSource.enumerated() {
                sectionDidUpdate(sectionNumber, new: newSectionFields, old: oldDataSource[sectionNumber])
            }
        }
        
        private func sectionDidUpdate(_ section: Int, new: [CellRepresentable], old: [CellRepresentable]) {
            guard new.count == old.count else {
                tableView.reloadSections([section], with: .fade)
                return
            }
            
            for visibleIndexPath in tableView.indexPathsForVisibleRows ?? [] {
                guard visibleIndexPath.section == section else { continue }
                guard let cell = tableView.cellForRow(at: visibleIndexPath) else { continue }
                
                dataSource[section][visibleIndexPath.row].configure(cell: cell)
            }
        }
        
        /// Arrange models by sections
        private static func arrangeBySections(network: Input.Network) -> [[CellRepresentable]] {
            let inputFields = network.inputFields.filter {
                if let field = $0 as? InputField, field.isHidden { return false }
                return true
            }
            var dataSource = [inputFields]
            
            var checkboxes = [Input.Field.Checkbox]()
            for field in [network.autoRegistration, network.allowRecurrence] where !field.isHidden {
                checkboxes.append(field)
            }
            
            dataSource.append(checkboxes)
            
            return dataSource
        }
    }
}

extension Input.Table.Controller: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellRepresentable = dataSource[indexPath.section][indexPath.row]
        let cell = cellRepresentable.dequeueCell(for: tableView, indexPath: indexPath)
        cellRepresentable.configure(cell: cell)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
     }
}

extension Input.Table.Controller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = tableView.cellForRow(at: indexPath)
        row?.becomeFirstResponder()
    }
}

extension Input.Table.Controller: InputCellDelegate {
    func inputCellDidEndEditing(at indexPath: IndexPath) {
        guard let model = dataSource[indexPath.section][indexPath.row] as? Validatable else { return }
        
        model.validateAndSaveResult(option: .preCheck)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func inputCellBecameFirstResponder(at indexPath: IndexPath) {
        // Don't show an error text when input field is focused
        if let model = dataSource[indexPath.section][indexPath.row] as? Validatable,
            model.validationErrorText != nil {
            model.validationErrorText = nil
            
            tableView.beginUpdates()
            
            switch tableView.cellForRow(at: indexPath) {
            case let textFieldViewCell as Input.Table.TextFieldViewCell:
                textFieldViewCell.showValidationResult(for: model)
            default: break
            }
            
            tableView.endUpdates()
        }
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    func inputCellValueDidChange(to newValue: String?, at indexPath: IndexPath) {
        guard let model = dataSource[indexPath.section][indexPath.row] as? InputField else { return }
        model.value = newValue ?? ""
        
        inputChangesListener?.valueDidChange(for: model)
    }
}

extension Input.Table.Controller {
    /// Structure with section numbers
    fileprivate struct Section {
        static let inputFields = 0
        static let checkboxFields = 1
    }
}
#endif
