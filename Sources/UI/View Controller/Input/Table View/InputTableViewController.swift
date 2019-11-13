#if canImport(UIKit)
import UIKit

class InputTableController: NSObject {
    private let inputFields: [InputField]

    init(inputFields: [InputField]) {
        self.inputFields = inputFields
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
        let inputField = inputFields[indexPath.row]
        let cell = tableView.dequeueReusableCell(InputTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.inputField = inputField
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
