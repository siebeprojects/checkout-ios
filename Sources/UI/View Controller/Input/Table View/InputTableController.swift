#if canImport(UIKit)
import UIKit

class InputTableController: NSObject {
    private let network: PaymentNetwork
    let inputFields: [ViewRepresentable]
    
    init(network: PaymentNetwork) {
        self.network = network
        let factory = ViewRepresentableFactory(translator: network.translation)
        let inputElements = network.applicableNetwork.localizedInputElements ?? [InputElement]()
        inputFields = factory.make(from: inputElements)
        
        super.init()
    }
}

extension InputTableController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputFields.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InputTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.model = inputFields[indexPath.row]
        return cell
     }
}

extension InputTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = tableView.cellForRow(at: indexPath)
        row?.becomeFirstResponder()
    }
}
#endif
