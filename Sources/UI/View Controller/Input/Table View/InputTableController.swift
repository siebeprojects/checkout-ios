#if canImport(UIKit)
import UIKit

class InputTableController: NSObject {
    let network: PaymentNetwork
    unowned let tableView: UITableView
    private var cells: [CellRepresentable]
    
    init(network: PaymentNetwork, tableView: UITableView) {
        self.network = network
        self.tableView = tableView
        
        let factory = ViewRepresentableFactory(translator: network.translation)
        let inputElements = network.applicableNetwork.localizedInputElements ?? [InputElement]()
        cells = factory.make(from: inputElements)
        super.init()
    }
}

extension InputTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellRepresentable = cells[indexPath.row]
        let cell = cellRepresentable.dequeueConfiguredCell(for: tableView, indexPath: indexPath)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
     }
}

extension InputTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = tableView.cellForRow(at: indexPath)
        row?.becomeFirstResponder()
    }
}

extension InputTableController: InputCellDelegate {
    func inputCellBecameFirstResponder(at indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
    }
}
#endif
